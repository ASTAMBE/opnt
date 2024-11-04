<?php
require 'jwt/vendor/autoload.php';
  use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$fromIndex="";
$toIndex="";
$topicid = $postData['topicid'];
$userid = $postData['userid'];
$token = $headers['Token'];

if(isset($postData['from'])){
  $fromIndex = $postData['from'];
}
if(isset($postData['to'])){
  $toIndex = $postData['to'];
}
if (!$topicid || $topicid == "" || !$userid || $userid == "" || $token == ""){
     $response = "{\"status\": \"error\"}";
    die($response);
}
else{

if ($fromIndex == ""){
  $fromIndex = 0;
}
if ($toIndex == ""){
  $toIndex = 20;
}
// if($verify=verify_jwt_by_userid($token,$userid)){

// }else{
// 			$response =array("status"=>"Authentication Failed");
// 			http_response_code(401);
// 			print json_encode($response);
// 			die();
// }


 $json_arry = array();
$q = "CALL getInstreamNW( \"$userid\",  \"$topicid\",\"$fromIndex\",\"$toIndex\");"; 
$result = mysqli_query($db,$q);

if($result == TRUE){
      while (($row = mysqli_fetch_assoc($result))){
             // $json_arry[] =  $row;
$json['POST_ID'] = $row['POST_ID'];
$json['TOPICID'] =  $row['TOPICID'];
$json['POST_DATETIME'] = $row['POST_DATETIME'];
$json['POST_BY_USERID'] = $row['POST_BY_USERID'];
$json['USERNAME'] =$row['USERNAME'];
$json['MEDIA_CONTENT'] =$row['MEDIA_CONTENT'];
$json['MEDIA_FLAG'] =$row['MEDIA_FLAG'];
$json['DP_URL'] = $row['DP_URL'];
$json['TOTAL_NS'] = $row['TOTAL_NS'];
$json['LCOUNT'] = $row['LCOUNT'];
$json['HCOUNT'] = $row['HCOUNT'];
$json['POST_ACTION_TYPE'] = $row['POST_ACTION_TYPE'];
$json['UU_ACTION'] = $row['UU_ACTION'];
$json['POST_COMMENT_COUNT'] = $row['POST_COMMENT_COUNT'];
$json['POST_CONTENT'] = $row['POST_CONTENT'];
array_push($json_arry, $json); 

       }
      $r =  json_encode($json_arry);
      echo $r;
    }
    else{
    $response = "{\"status\": \"error\"}";
    echo $r;
    }
}


?>