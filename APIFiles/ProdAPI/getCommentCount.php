<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');
 
  $userid = $postData['userid'];
  $postid = $postData['postid'];
  $token = $headers['Token'];

    
    if (!$userid || $userid == "" || !$postid || $postid == "" || $token == ""){
        $response =array("status"=>"error");
        http_response_code(500);
        print json_encode($response);
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

        $q = "call getCommentCount(\"$userid\", \"$postid\");";
        $result = mysqli_query($db,$q);
        if($result == TRUE){
			$val =array("status"=>"success");
			while (($row = mysqli_fetch_assoc($result))){
				    $json_arry['status'] =  $val['status'];
					$json_arry['data'] =  $row;	
			 }
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

