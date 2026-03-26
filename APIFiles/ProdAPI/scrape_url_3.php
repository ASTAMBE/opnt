<?php

//---------------------------------

function checkURL($url,$db){

    $sql = 'SHOW PROCEDURE STATUS WHERE Name="checkURL";';
    $response = mysqli_query($db,$sql);


    if($response->num_rows){

        $sql = "CALL checkURL(\"$url\")";

        $result = mysqli_query($db,$sql);

    } else {

        $sql = 'SELECT * FROM WEB_SCRAPE_RAW WHERE NEWS_URL LIKE "'.$url.'";';
        $result = mysqli_query($db,$sql);
    }

    return $result;
}

function insertWebURL($url,$title,$description,$imageUrl,$db){

    $sql = 'SHOW PROCEDURE STATUS WHERE Name="insertWebURL";';
    $response = mysqli_query($db,$sql);

    if($response->num_rows){

        $sql = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";

        $result = mysqli_query($db,$sql);

    } else {

        $sql =
            'INSERT INTO WEB_SCRAPE_RAW ('.
                'NEWS_URL,NEWS_HEADLINE,NEWS_EXCERPT,NEWS_PIC_URL'.
            ') VALUES ('.

                '"'.$url.'",'.
                '"'.mysqli_real_escape_string($db,$title).'",'.
                '"'.mysqli_real_escape_string($db,$description).'",'.
                '"'.$imageUrl.'"'.

            ');';

        $result = mysqli_query($db,$sql);

    }
   
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
//---------------------------------



include('includeHeader.inc.php');

require __DIR__ . '/vendor/autoload.php';

//----------------------------------------

use LinkPreview\LinkPreview;



// for using post
if(isset($postData['url'])){
    $url = $postData['url'];
}

// for command mode.
// eg:
//   $> php scrape_url_3.php <url>
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

    $linkPreview = new LinkPreview($url);

    $parsed = $linkPreview->getParsed();

    $url          = $parsed['general']->getUrl();

    $title        = process_characters($parsed['general']->getTitle(),false);

    $description  = process_characters($parsed['general']->getDescription(),false);

    $imageUrl     = $parsed['general']->getImage();


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