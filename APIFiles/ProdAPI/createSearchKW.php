<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');


$tid = $postData['topicid'];
$uuid = $postData['userid'];
$userKW = addslashes($postData['userKW']);
$usercart = $postData['usercart'];
$token = $headers['Token'];


if (!$tid || $tid == ""|| !$uuid || $uuid == ""|| !$userKW || $userKW == ""
|| !$usercart || $usercart == "" || $token == ""){
	$response = "{\"status\": \"invalid parameters error\"}";
	die($response);
}
else {
	
	if($verify=verify_jwt_by_userid($token,$uuid)){

	}else{
				$response =array("status"=>"Authentication Failed");
				http_response_code(401);
				print json_encode($response);
				die();
	}

	$json_arry = array();
	$q = "CALL createSearchKW(\"$tid\", \"$uuid\", \"$userKW\" , \"$usercart\");";
	$result = mysqli_query($db,$q);


	if($result == TRUE){

		while (($row = mysqli_fetch_assoc($result))) {
                  $json_arry[] =  $row;
           	}
         	$r =  json_encode($json_arry);
         	echo $r;

	}
	else{
		$response = "{\"status\": \"The topic already exists.\"}";
	}
	//echo $response;
}

?>




