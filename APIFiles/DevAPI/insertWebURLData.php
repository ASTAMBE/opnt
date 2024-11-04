<?php
include('includeHeader.inc.php');
//echo "test partha";
//ini_set('display_errors', '1');
//echo "5_Parthu_112::<pre>";

	$url = $postData['WEB_URL'];
 	$title = $postData['URL_TITLE'];
 	$description = $postData['URL_DESCRIPTION'];
 	$imageUrl = $postData['IMAGE_URL'];



    if (!$url || $url == ""|| !$title || $title == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{

        $q = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";

		$result = mysqli_query($db,$q);
		 //echo $q;
		$response = "{\"status\": \"success\"}";
		 echo $response;
    }  
    
 ?>