<?php
include('includeHeader.inc.php');


$topicid = $postData['topicid'];
$userid = $postData['userid'];


if (!$topicid || $topicid == ""|| !$userid || $userid == "" ){
	$response = "{\"status\": \"invalid parameters error\"}";
	die($response);
}
else{

	$message = addslashes($postData['postInfo']['message']);
	$embedded_content = $postData['postInfo']['embedded_content'];
	$embedded_flag = $postData['postInfo']['embedded_flag'];
	$postor_country_code = $postData['postInfo']['country_code'];
	$json_arry = array();
	$q = "CALL newPost(\"$topicid\", \"$userid\",\"$message\",\"$embedded_content\",\"$embedded_flag\", \"$postor_country_code\");";
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




