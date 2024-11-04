<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

   $userid = $postData['userid'];
   $token = $headers['Token'];

   $str= $postData['topicid'];
    if (!$userid || $userid == "" || !$str || $str == "" || $token == ""){
      $response = "{\"status\": \"error\"}";
      http_response_code(500);
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
      $str= $postData['topicid'];
      $strArray=explode(',',$str);
		foreach ($strArray as $topic) {
				$q = "call saveUserInterests(\"$userid\", \"$topic\" ); ";    
				$result = mysqli_query($db,$q);
        }
        if($result == TRUE){
            $response = "{\"status\": \"success\"}";
            http_response_code(200);
            echo $response;
        }else{
            $response = "{\"status\": \"error\"}";
            http_response_code(500);
            echo $response;

        }
        
    }
  
  
 ?>
