<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

 $Apple_userid = $postData['Apple_userid'];
 $device_serial = $postData['device_serial'];

 if (!$Apple_userid || $Apple_userid == "" || !$device_serial || $device_serial == ""){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{

 $q = "CALL loginWithAppleUserApp(\"$Apple_userid\", \"$device_serial\");";
        $result = mysqli_query($db,$q);    
      
      if($result == TRUE){
            while (($row = mysqli_fetch_assoc($result))){
              $starttime= time();
              $exptime = time()+ (14 * 24 * 60 * 60);
              $token_payload = [
              'uuid' => $row['USERID'],
              'username' => $row['USERNAME'],
              'country_code' => $row['COUNTRY_CODE'],
              "iat" => $starttime,
              "exp" => $exptime
              ];
              $jwt = JWT::encode($token_payload , base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
              $row['token']=$jwt;
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
