<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$username = $postData['userid'];
$token = $headers['Token'];

if (!$username || $username == "" || $token == ""){
		 $response = "{\"status\": \"error\"}";
	 	die($response);
 }
else{

	if($verify=verify_jwt_by_userid($token,$username)){

	}else{
				$response =array("status"=>"Authentication Failed");
				http_response_code(401);
				print json_encode($response);
				die();
	}
	 	$json_arry = array();
 //	$q = "SELECT DISTINCT A.TOPICID, B.TOPIC, B.CODE FROM OPN_USER_CARTS A, OPN_TOPICS B WHERE A.USERID = \"$username\" AND A.TOPICID = B.TOPICID ORDER BY A.TOPICID;";//"SELECT DISTINCT  TOPICID, TOPIC,CODE FROM OPN_USER_CARTS WHERE USERID = \"$username\"" ;
$q = "call getUserTopics(\"$username\");";

 	//	echo $q;
	$result = mysqli_query($db,$q);
		if($result == TRUE){
	while (($row = mysqli_fetch_assoc($result))){
    		$json_arry[] =  $row;
		 }	
	$r =  json_encode($json_arry);
	echo $r;
	}
	else{
	$response = "{\"status\": \"DB error\"}";
	echo $r;
	}
}
//}

?>
