<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

 $username = $postData['username'];
 $logintype = $postData['logintype'];

 if (!$username|| $username == "" || !$logintype || $logintype == ""){
    $response =array("status"=>"error");
    http_response_code(500);
    print json_encode($response );
 }
else{
  $q = "CALL usernamelist(\"$username\", \"$logintype\")";
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
                $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
                $row['token']=$jwt;
                $json_arry[] =  $row;
           	}
             http_response_code(200);
             print json_encode($json_arry);
       }
       else{
        $response =array("status"=>"error");
        http_response_code(500);
        print json_encode($response );
        }
}

?>
