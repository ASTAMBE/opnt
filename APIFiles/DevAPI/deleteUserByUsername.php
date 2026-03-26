<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

    $username = $postData['username'];
    $login_type_os = $postData['login_type_os'];
    $userid = $postData['userid'];
    $token = $headers['Token'];
  
    if (!$username || $username == "" || !$login_type_os || $login_type_os == ""){
        $response = "{\"status\": \"error\"}";
    } else {

        if ($verify=verify_jwt_by_userid($token, $userid)) {
               
            $q = "CALL deleteUserByUsername(\"$username\", \"$login_type_os\");";
            $result = mysqli_query($db,$q);
    
            if ($result) {
                $response = "{\"status\": \"success\"}";
            } else {
                $response = "{\"status\": \"error\"}";
            }

        } else {
            $response = array("status"=>"Authentication Failed");
            http_response_code(401);
            print json_encode($response);
            die();
        }
    }

    echo $response;

?>
