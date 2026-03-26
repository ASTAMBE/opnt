<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader1.inc.php');

	$userid = $postData['userid'];
	$country_code = $postData['country_code'];
	if (!$userid || $userid == "" || !$country_code || $country_code == ""){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
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
}
?>
