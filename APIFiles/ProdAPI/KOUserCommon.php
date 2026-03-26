<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

	$userid = $postData['userid'];
	$KOtype = $postData['KOtype'];
	$SourceId = $postData['SourceId'];
	$token = $headers['Token'];
	
	if (!$userid || $userid == "" || !$KOtype || $KOtype == ""
	|| !$SourceId || $SourceId =="" || $token == "" ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		if($verify=verify_jwt_by_userid($token,$userid)){

		}else{
					$response =array("status"=>"Authentication Failed");
					http_response_code(401);
					print json_encode($response);
					die();
		}
		$q = "CALL KOUserCommon(\"$userid\",\"$KOtype\",\"$SourceId\");";
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