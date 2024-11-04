<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');


 $topic_id = $postData['topic_id'];
 $uuid = $postData['uuid'];
 $token = $headers['Token'];

if (!$topic_id|| $topic_id == "" || !$uuid || $uuid == "" || $token == ""){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
 if($verify=verify_jwt_by_userid($token,$uuid)){

}else{
			$response =array("status"=>"Authentication Failed");
			http_response_code(401);
			print json_encode($response);
			die();
}

 $query = "CALL likemindedcount(\"$uuid\",\"$topic_id\");";

 $result = mysqli_query($db,$query);
      if($result == TRUE){
                 $row = mysqli_fetch_assoc($result);
                  $count =$row['CNT'];
                  $topicname =  $row['TOPICNAME'];
                echo  $response = "[{\"count\": \"$count\",\"topicname\":\"$topicname\"}]";
        }
       else{
            $response = "{\"status\": \"error\"}";
          echo $r;
        }
?>
