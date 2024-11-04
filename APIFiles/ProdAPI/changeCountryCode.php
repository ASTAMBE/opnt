<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

function verify_jwt($token,$userid){
	$Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
	   $decoded = JWT::decode($token, base64_decode(strtr($Secret_key, '-_', '+/')), ['HS256']);
	   $verify = json_decode(json_encode($decoded), true);
		   if (array_key_exists("status",$verify)){
			   return 0;
		   }else{
		   if($verify['uuid']==$userid){
			   return 1;
		   }
		   else{
			   return 0;
		   }
		   }
   }
	$userid = $postData['userid'];
	$country_code = $postData['country_code'];
	$token = $postData['token'];
	if (!$userid || $userid == "" || !$country_code || $country_code == "" || !$token ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		if($verify=verify_jwt($token,$userid)){
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
