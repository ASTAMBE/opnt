<?php

include('includeHeader.inc.php');



$headers = parseRequestHeaders();

if (!authenticateGet($headers)){
  header("HTTP/1.1 401 Unauthorized");
  exit;
}
   
$postData = getPostData();

$userid = $postData['userid'];
$topic_id = $postData['topic_id'];



if (!$userid || $userid == "" || !$topic_id || $topic_id == "" ){
  	$response = "{\"status\": \"invalid parameters error\"}";
  	die($response);
}
else{
    
	$json_arry = array();
    $q = "CALL NEWCART_TOP( \"$userid\",  \"$topic_id\");";
    $result = mysqli_query($db,$q);
    if($result == TRUE){
        $response = "{\"status\": \"success\"}";
    }
    else{
        $response = "{\"status\": \"error\"}";
    }
	echo $response;
}
?>
