<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;  
include('includeHeader.inc.php');
include('jwt_verify.php');

$fromIndex="";
$toIndex="";

$userid 		= $postData['userid'];
$topicid 		= $postData['topicid'];
$searchterm 	= $postData['searchterm'];
$token = $headers['Token'];

if(isset($postData['from'])){
  $fromIndex = $postData['from'];
}
if(isset($postData['to'])){
  $toIndex = $postData['to'];
}
if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$searchterm || $searchterm == "" || $token == ""){
     $response = "{\"status\": \"error\"}";
    die($response);
}
$searchterm = $searchterm.'*';
if ($fromIndex == ""){
  $fromIndex = 0;
}
if ($toIndex == ""){
  $toIndex = 20;
}
if($verify=verify_jwt_by_userid($token,$userid)){

}else{
			$response =array("status"=>"Authentication Failed");
			http_response_code(401);
			print json_encode($response);
			die();
}
  $q = "call userPostSearch(\"$userid\", \"$topicid\",\"$searchterm\",\"$fromIndex\",\"$toIndex\");";
	$json_arry = array();
	$json = array();
    $result = mysqli_query($db,$q);
    if($result == TRUE){
    	while (($row = mysqli_fetch_assoc($result))){
          	array_push($json, $row); 
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
 ?>
