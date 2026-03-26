<?php

include('includeHeader.inc.php');

print_r($_REQUEST);
$url = $postData['url'];


// Enter the required url
//$url = 'https://edition.cnn.com/2018/08/28/politics/lanny-davis-trump-tower-michael-cohen/index.html';
//$url = 'https://arstechnica.com/tech-policy/2018/06/dark-web-vendor-oxymonster-turns-out-to-be-a-frenchman-with-luscious-beard/';


//----------------------------------------

require __DIR__ . '/vendor/autoload.php';

use LinkPreview\LinkPreview;

//echo 'insert_procedure staring';

//get_url_preview();

function extract_url_data($url){
	$url = "https://www.cnn.com/2018/10/20/opinions/saudi-arabia-khashoggi-statement-robertson-intl/index.html";
    if(!filter_var($url, FILTER_VALIDATE_URL)) {
        echo($url.' is not a valid URL !!!!');
        die;
    }

    $linkPreview = new LinkPreview($url);
    $parsed = $linkPreview->getParsed();

    return $parsed;
}

function insert_procedure($db, $parsed){


    $url         = $parsed['general']->getUrl();
    $title       = mysqli_real_escape_string($db,$parsed['general']->getTitle());
    $description = mysqli_real_escape_string($db,$parsed['general']->getDescription());
    $imageUrl       = $parsed['general']->getImage();

    $sql = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";

    echo $sql.PHP_EOL;

    $result = mysqli_query($db,$sql);
    if($result == FALSE){
        $response = "{\"status\": \"error\"}";
        die($response);
    }  
   
}

function check_procedure($db, $url){

    // procedure to check
    $sql = "CALL checkURL(\"$url\")";

    echo "check_procedure".PHP_EOL;
    echo $sql.PHP_EOL;


    $result = mysqli_query($db,$sql);

    if($result == FALSE){
        $response = "{\"status\": \"error\"}";
        die($response);
    }  

    if ((mysqli_num_rows($rePHP_EOLsult) > 0) || !is_null($result)) {
        $data = mysqli_fetch_assoc($result);
        return $data;
    } else {
        return null;
    }
}


//----------------------------------------


$data = null;

if(is_null($data=check_procedure($db, $url))){

    echo 'url not found in the db';

    $parsed = extract_url_data($url);

    //insert_procedure($db, $parsed);

    $url         = $parsed['general']->getUrl();
    $title       = mysqli_real_escape_string($db,$parsed['general']->getTitle());
    $description = mysqli_real_escape_string($db,$parsed['general']->getDescription());
    $imageUrl       = $parsed['general']->getImage();
	//echo "98::parsed::<pre>";print_r($parsed);die;
    $sql = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";

    $result = mysqli_query($db,$sql);
	var_dump($db);//die;
    if($result == FALSE){
        $response = "{\"status\": \"error\"}";
        echo"105::Errormessage:".mysql_errno();
		printf("<br>106::Errormessage: %s\n", $mysqli->error);
        die($response);
    }  
	echo "110::cmngout";die;

    $data['WEB_URL']         = $parsed['general']->getUrl();
    $data['URL_TITLE']       = mysqli_real_escape_string($db,$parsed['general']->getTitle());
    $data['URL_DESCRIPTION'] = mysqli_real_escape_string($db,$parsed['general']->getDescription());
    $data['IMAGE_URL']       = $parsed['general']->getImage();
}

echo json_encode($data);



function get_url_preview() {
	
	$target_url = urlencode("https://www.cnn.com/2018/10/20/opinions/saudi-arabia-khashoggi-statement-robertson-intl/index.html");
	$key = "5bc96d7c3cc95dc26c5197ace46abe960095b7a46a8e9";

	$ret = file_get_contents("https://api.linkpreview.net?key=$key&q=$target_url");
	
	$aUrlPreviewData[] = object_to_array(json_decode($ret));

	if(count($aUrlPreviewData) > 0) {
		foreach($aUrlPreviewData as $aUrlData) {
			echo "Title::".$aUrlData['title']."<br>";
			echo "Description::".$aUrlData['description']."<br>";
			echo "Image::";
			echo "<img src='".$aUrlData['image']."'/>";
			echo"<br>";
			echo "Url::".$aUrlData['url']."<br>";
		}
	}
}



function object_to_array($data)
{
    if (is_array($data) || is_object($data))
    {
        $result = array();
        foreach ($data as $key => $value)
        {
            $result[$key] = object_to_array($value);
        }
        return $result;
    }
    return $data;
}
?>