<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

 $username = $postData['username'];
 $country_code = $postData['country_code'];
 $fname = $postData['fname'];
 $lname = $postData['lname'];
 $Apple_userid = $postData['Apple_userid'];
 $device_serial = $postData['device_serial'];
 $dp_url = $postData['dp_url'];
  
  if (!$username || $username == "" || !$country_code || $country_code == ""  || !$Apple_userid || $Apple_userid == "" || !$device_serial || $device_serial == ""){
         $rtn = array ("status"=> "error");
          http_response_code(500);
          print json_encode($rtn);   
  }
  else{
    $q = "CALL createAppleUserTokenApp(\"$username\", \"$country_code\", \"$fname\", \"$lname\",\"$Apple_userid\",\"$dp_url\",\"$device_serial\");";
    $result = mysqli_query($db,$q);
    if($result == TRUE){
           $json_arry=array();
        $val =array("status"=>"success");
        $json1['status'] =  $val['status'];
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
            $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
              $json1['status'] =  "success";
              $json1['token'] =  $jwt;
              $data['data']= $json_arry;
              $array3 = array_merge($json1,$data);
              http_response_code(200);
              print json_encode($array3);
    }else{
        $rtn = array ("status"=> "Username Exists");
        http_response_code(500);
        print json_encode($rtn); 
    }
  }
  
  
  ?>