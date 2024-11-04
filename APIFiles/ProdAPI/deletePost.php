
<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

  $userid = $postData['userid'];
  $postid = $postData['postid'];
  $token = $headers['Token'];

    
    if (!$userid || $userid == "" || !$postid || $postid == "" || $token == ""){
      	$response = "{\"status\": \"invalid parameters error\"}";
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

    	$json_arry = array();

  //      $q = "DELETE FROM OPN_POSTS WHERE POST_ID = \"$postid\";";

  $q = "call deletePost(\"$userid\", \"$postid\");";

        $result = mysqli_query($db,$q);
        if($result == TRUE){
            $response = "{\"status\": \"success\"}";
        }
        else{
            $response = "{\"status\": \"error\"}";
        }
    	echo $response;
    }
?>
