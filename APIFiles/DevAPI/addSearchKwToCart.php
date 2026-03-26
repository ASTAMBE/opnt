<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('jwt_verify.php');
include('includeHeader.inc.php');
//echo "test partha";
//ini_set('display_errors', '1');
//echo "5_Parthu_112::<pre>";

	$topicid = $postData['topicid'];
	 $userid = $postData['userid'];
	 $token = $headers['Token'];


    if (!$topicid || $topicid == ""|| !$userid || $userid == "" || $token == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
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

		foreach (json_decode($postData['topiccarts']) as $topic) {

		$q = "call addSearchKwToCart( \"{$topic->TOPICID}\", \"$userid\", \"{$topic->CART}\" , \"{$topic->KEYID}\"); ";
			$result = mysqli_query($db,$q);
		 //echo $q;
		}
		$response = "{\"status\": \"success\"}";
		 echo $response;
    }  
    
 ?>