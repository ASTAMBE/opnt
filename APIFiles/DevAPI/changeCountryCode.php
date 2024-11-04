<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');


	$userid = $postData['userid'];
	$country_code = $postData['country_code'];
	$token = $headers['Token'];

	
	if (!$userid || $userid == "" || !$country_code || $country_code == "" || !$token ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		if($verify=verify_jwt_by_userid($token,$userid)){
		$q = "CALL changeCountryCode(\"$userid\",\"$country_code\");";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			$response =array("status"=>"success");
			http_response_code(200);
			print json_encode($response);
		}
		else{
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
		}
		}else{
			$response =array("status"=>"Authentication Failed");
			http_response_code(401);
			print json_encode($response);
		}
}
?>
