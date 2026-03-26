<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$userid          = $postData["userid"];
$actionSource    = $postData["actionSource"];
$actionType      = $postData["actionType"];
$sourceID        = $postData["sourceID"];
$token = $headers['Token'];

if (!$userid || $userid == "" || !$actionSource || $actionSource == "" || !$actionType || $actionType == "" || !$sourceID || $sourceID == "" || $token == ""){
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
$q = "CALL userActionCommon(\"$userid\", \"$actionSource\", \"$actionType\",\"$sourceID\");";
$result = mysqli_query($db,$q);

if($result == TRUE){
  $response = "{\"status\": \"success\"}";
}
else{
 $response = "{\"status\": \"error\"}";
}
echo $response;

?>


