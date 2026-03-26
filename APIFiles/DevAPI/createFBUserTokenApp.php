<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

 $username = $postData['username'];
 $country_code = $postData['country_code'];
 $fb_username = $postData['fb_username'];
 $fb_userid = $postData['fb_userid'];
 $device_serial = $postData['device_serial'];
 $dp_url = $postData['dp_url'];

 //Added url optional ;
 if (!$username || $username == "" ||!$fb_userid || $fb_userid=="" ||
      !$country_code || $country_code == "" ||
      !$device_serial || $device_serial == "") {
         $response = "{\"status\": \"error\"}";
         http_response_code(500);
        die($response);
 }
else{
        $q = "call createFBUserTokenApp(\"$username\", \"$country_code\", \"$fb_username\", \"$fb_userid\", \"$device_serial\",\"$dp_url\");";
        $result = mysqli_query($db,$q);
        //echo $q;        
      if ($result == TRUE) {
        $json_arry=array();
        $jwt="";
        $userid="";
        while (($row2 = mysqli_fetch_assoc($result))){
          $userid=$row2['USERID'];
          array_push($json_arry, $row2); 
            } 
            $starttime= time();
            $exptime = time()+ (14 * 24 * 60 * 60);
            $token_payload = [
                'uuid' => $userid,
                'username' => $username,
                'country_code' => $country_code,
                "iat" => $starttime,
                "exp" => $exptime
            ];
            // This is your id token
            $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
              $json1['status'] =  "success";
              $json1['token'] =  $jwt;
              $data['data']= $json_arry;
              $array3 = array_merge($json1,$data);
              http_response_code(200);
              print json_encode($array3);
      }
        else{
          http_response_code(500);
         echo  $response = "{\"status\": \"Username Exists\"}";
        }
}
?>
