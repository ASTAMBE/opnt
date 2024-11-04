<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
$Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
 
  $userid = $postData['userid'];
  $username = $postData['username'];

    if (!$userid || $userid == "" || !$username || $username == ""){
        $response =array("status"=>"error");
        http_response_code(500);
        print json_encode($response);
    }
    else{
        $starttime= time();
        $exptime = time()+ (14 * 24 * 60 * 60);
        $token_payload = [
            'uuid' => $userid,
            'username' => $username,
            "iat" => $starttime,
            "exp" => $exptime
        ];
        // This is your id token
        $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
        $q = "call addAuthTokenToUser(\"$username\",\"$userid\",\"$jwt\");";
        $result = mysqli_query($db,$q);
        if($result == TRUE){
			$json_arry =array("status"=>"success","token"=>$jwt);
			http_response_code(200);
			print json_encode($json_arry);
		}
        else{
            $response =array("status"=>"error");
            http_response_code(500);
            print json_encode($response);
        }
    }
?>

