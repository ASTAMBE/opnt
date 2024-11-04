<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$postid = $postData['postid'];
$userid = $postData['userid'];
$token = $headers['Token'];


if (!$postid || $postid == "" || !$userid || $userid=="" || $token==""){
   $response = "{\"status\": \"error\"}";
   die($response);
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
    $q = "CALL getPostDetails(\"$userid\",\"$postid\");";
    $result = mysqli_query($db,$q);
  	if($result == TRUE){
    	while (($row = mysqli_fetch_assoc($result))){
      		$json[] =  $row;
    	} 
		if(empty($json)){
			$r =  $response = "{\"status\": \"Post not found\"}";
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