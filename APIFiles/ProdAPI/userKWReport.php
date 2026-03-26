<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$userid     = $postData["userid"];
$topicid    = $postData["topicid"];
$keyid      = $postData["keyid"];
$comment    = $postData["comment"];
$token = $headers['Token'];

if (!$userid || $userid == "" || !$topicid || $topicid == "" || !$keyid || $keyid == "" || !$comment || $comment == "" || $token == ""){
    $response = "{\"status\": \"error\"}";
    die($response);
}
if($verify=verify_jwt_by_userid($token,$userid)){

}else{
			$response =array("status"=>"Authentication Failed");
			http_response_code(401);
			print json_encode($response);
			die();
}
$comment = addslashes($comment);
$q = "CALL userKWReport(\"$userid\", \"$topicid\", \"$keyid\",\"$comment\");";
$result = mysqli_query($db,$q);

if($result == TRUE){
  $response = "{\"status\": \"success\"}";
}
else{
 $response = "{\"status\": \"error\"}";
}
echo $response;

?>


