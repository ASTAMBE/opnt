<?php

// most probably you will not need to
// change these
$max_retry = 5;
$retry_delay = 0;

//---------------------------------

require 'phpQuery/phpQuery.php';

function checkURL($url,$db){

  //  $sql = 'SHOW PROCEDURE STATUS WHERE Name="checkURL";';
 //   $response = mysqli_query($db,$sql);


 //   if($response->num_rows){

        $sql = "CALL checkURL(\"$url\")";

        $result = mysqli_query($db,$sql);

 //   } else {

   //     $sql = 'SELECT * FROM WEB_SCRAPE_RAW WHERE NEWS_URL LIKE "'.$url.'";';
     //   $result = mysqli_query($db,$sql);
    //}

    return $result;
}

function insertWebURL($url,$title,$description,$imageUrl,$db){

//    $sql = 'SHOW PROCEDURE STATUS WHERE Name="insertWebURL";';
  //  $response = mysqli_query($db,$sql);

   // if($response->num_rows){

        $sql = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";

        $result = mysqli_query($db,$sql);

   // } else {

     //   $sql =
       //     'INSERT INTO WEB_SCRAPE_RAW ('.
         //       'NEWS_URL,NEWS_HEADLINE,NEWS_EXCERPT,NEWS_PIC_URL'.
           // ') VALUES ('.

             //   '"'.$url.'",'.
               // '"'.mysqli_real_escape_string($db,$title).'",'.
             //   '"'.mysqli_real_escape_string($db,$description).'",'.
              //  '"'.$imageUrl.'"'.

           // ');';

     //   $result = mysqli_query($db,$sql);

  //  }
   
    return $result;
}

function process_characters($text,$more=true,$numchars=null,$type='UTF-8'){

    $text = trim($text);

    $text = strip_tags($text);

    $text = html_entity_decode($text, ENT_QUOTES, $type);

    $text = str_replace('"','“',$text);

    $text = str_replace(array("\r", "\n"), ' , ', $text);

    $text = mb_substr($text, 0, $numchars, $type);

    if($more){
        $text .= "...";
    }

    return $text;
}

function object_to_array($data) {

    if (is_array($data) || is_object($data)) {

        $result = array();

        foreach ($data as $key => $value) {

            $result[$key] = object_to_array($value);

        }

        return $result;

    }

    return $data;
}

function get_url($url,$max_retry,$retry_delay){

    $retry = 0;

    // get page html
    do{
        $string = @file_get_contents($url);
        if($string===false){

            sleep($retry_delay);
            echo PHP_EOL.'sleeping for '.$url.PHP_EOL;

            if($retry>=$max_retry){
                echo $max_retry.' unsuccessful retried to '.$url.PHP_EOL;
                echo 'Abrubt Ending.';
                die;
            }
        }
        $retry++;
    }while($string===false);

    return $string;
}

//---------------------------------

include('includeHeader.inc.php');

//----------------------------------------


// for using post
if(isset($postData['url'])){
    $url = $postData['url'];
}

else if(isset($argv[1])){
    $url = $argv[1];
}

else{
    die('No URL Mentioned');
}



$response = checkURL($url,$db);

$num_rows = $response->num_rows;


if($num_rows == 0) {


    // Free result set
    $response->close();
    $db->next_result();


    $string = get_url($url,$max_retry,$retry_delay);


    $string = phpQuery::newDocument($string);




    $count = count(pq('meta'));



    $og_url      = null;
    $title       = null;
    $description = null;
    $imageUrl    = null;

    for($i=0;$i<$count;$i++){

        if(isset($og_url)&&isset($title)&&isset($description)&&isset($imageUrl)){
            break;
        }

        $meta = pq('meta')->eq($i);

        if(!$meta->attr('property')) {
            continue;
        };


        switch($meta->attr('property')){
            case 'og:url' :
                // $og_url = pq($meta)->attr('content');
                $og_url = $url;
                break;
            case 'og:title' :
                $title = process_characters(pq($meta)->attr('content'),false);
                break;
            case 'og:description' :
                $description = process_characters(pq($meta)->attr('content'));
                break;
            case 'og:image' :
                $imageUrl = pq($meta)->attr('content');
                break;
        }
    }

    if(($og_url != $url)&&(isset($og_url))) {

        $url = $og_url;

        $response2 = checkURL($og_url,$db);

        if($response2->num_rows != 0){

            $data['WEB_URL']         = $url;
            $data['URL_TITLE']       = $title ;
            $data['URL_DESCRIPTION'] = $description;
            $data['IMAGE_URL']       = $imageUrl ;

            echo json_encode($data);
            die;

        }


        $response2->close();
        $db->next_result();
    }


    $result = insertWebURL($url,$title,$description,$imageUrl,$db);






    if($result == FALSE){

        $response = "{\"status\": \"error\"}";

        die($response);

    }


    $data['WEB_URL']         = $url;

    $data['URL_TITLE']       = $title ;

    $data['URL_DESCRIPTION'] = $description;

    $data['IMAGE_URL']       = $imageUrl ;



    echo json_encode($data);

} else {

    while ($db_obj = $response->fetch_object()) {

        $json_array[] = object_to_array($db_obj);

    }


    echo json_encode($json_array[0]);

}
?>