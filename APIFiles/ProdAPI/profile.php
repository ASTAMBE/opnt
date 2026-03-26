<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$userid = $postData['userid'];
$token = $headers['Token'];

if (!$userid || $userid == "" || $token == ""){
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
$q = "CALL profilephp(\"$userid\");";

$result = mysqli_query($db,$q);
      if($result == TRUE){
      while (($row = mysqli_fetch_assoc($result))){
              $json_arry[] =  $row;
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
