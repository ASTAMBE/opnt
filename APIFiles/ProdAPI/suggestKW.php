<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$userid = $postData['userid'];
$token = $headers['Token'];


if (!$userid || $userid=="" || $token==""){
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
    $q = "CALL suggestKW(\"$userid\");";
    $result = mysqli_query($db,$q);

  	if($result == TRUE){
		$date=array('DATE'=>date("d-m-Y"), "CART"=>"");
    	while (($row = mysqli_fetch_assoc($result))){
			$row=array_merge($row,$date);
      		$json[] =  $row;
    	} 
		if(empty(array_filter($json))){
			$r =  $response = "{\"status\": \"Keyword not found\"}";
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