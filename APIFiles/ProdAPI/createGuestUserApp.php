<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
  
  $postData = getPostData();
  
  $devicename = $postData['devicename'];
  $country_code = $postData['country_code'];
  $device_serial = $postData['device_serial'];
  
  
  if (!$devicename || $devicename == "" || !$country_code || $country_code == "" || !$device_serial || $device_serial == ""){
    $rtn = array ("status"=> "error");
    http_response_code(500);
    print json_encode($rtn); 
  }
  else{
      
    $q = "CALL createGuestUserApp(\"$devicename\", \"$country_code\", \"$device_serial\");";
    $result = mysqli_query($db,$q);
    if($result == TRUE){
        $json_arry=array();
      while (($row = mysqli_fetch_assoc($result))){
        $userid=$row['USER_UUID'];
        array_push($json_arry, $row); 	
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
        $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
          $json1['status'] =  "success";
          $json1['token'] =  $jwt;
          $data['data']= $json_arry;
          $array3 = array_merge($json1,$data);
          http_response_code(200);
          print json_encode($array3);
      }  
   else{
    $rtn = array ("status"=> "error");
    http_response_code(500);
    print json_encode($rtn); 
  }
  }
  
  
  ?>
