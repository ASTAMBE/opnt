<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$postid = $postData['postid'];
$userid = $postData['userid'];
$reactType = $postData['reactType'];
$token = $headers['Token'];

if(isset($postData['from'])){
	$fromIndex = $postData['from'];
}
if(isset($postData['to'])){
	$toIndex = $postData['to'];
}
if (!$postid || $postid == "" || !$userid || $userid=="" || !$reactType || $reactType=="" || $token==""){
   $response = "{\"status\": \"error\"}";
   die($response);
}
if ($fromIndex == ""){
	$fromIndex = 0;
  }
  if ($toIndex == ""){
	$toIndex = 20;
  }
else{
	if($verify=verify_jwt_by_userid($token,$userid)){

	}else{
				$response =array("status"=>"Authentication Failed");
				http_response_code(401);
				print json_encode($response);
				die();
	}
	$json_arry = array();
	$json = array();
    $q = "CALL whoLHMyPost(\"$userid\",\"$postid\",\"$reactType\",\"$fromIndex\",\"$toIndex\");";
    $result = mysqli_query($db,$q);
  	if($result == TRUE){
    	while (($row = mysqli_fetch_assoc($result))){
      		$json[] =  $row;
    	} 
		if(empty($json)){
			$r =  $response = "{\"status\": \"Data not found\"}";
			echo $r;
		}
		else{
		  	$json_arry['status'] = 'success';
		  	$json_arry['data'] = $json;
		  	$r =  json_encode($json_arry);
		  	echo $r;
		}
    }
    else{
		$response = "{\"status\": \"error\"}";
		echo $r;
   	}
}
?>