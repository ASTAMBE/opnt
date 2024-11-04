<?php
 require 'jwt/vendor/autoload.php';
 use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$userid = $postData['userid'];
$token = $headers['Token'];

//$UID = $postData['userid'];

$topicid = $postData['topicid'];

$fromIndex = $postData['fromIndex'];
$toIndex = $postData['toIndex'];

if (!$userid || $userid == "" || !$topicid || $topicid == "" || $token == ""){

//  if (!$UID || $UID == "" || !$TID || $TID == ""){
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

   $q = "CALL networkNamesByUserName( \"$userid\",  \"$topicid\", \"$fromIndex\",  \"$toIndex\");";

  //  $q = "CALL networkNamesByUserName( \"$UID\",  \"$TID\", \"$fromIndex\",  \"$toIndex\");";


  $result = mysqli_query($db,$q);
  if($result == TRUE){
    while (($row = mysqli_fetch_assoc($result))){
      $json_arry[] =  $row;
    }
    if(isset($json_arry)){
      $r =  json_encode($json_arry);
      echo $r;
    }else{
     echo json_encode(array());
   }
   
 }
 else{
  $response = "{\"status\": \"error\"}";
  echo $response;
}
}


?>
