<?php
 require __DIR__ . '/s3/s3.php';
 require 'jwt/vendor/autoload.php';
 use \Firebase\JWT\JWT;
 include('includeHeader.inc.php');
 include('jwt_verify.php');
 include('sendNotification.php');

 $url_images= array();
 $List="";
 $media_content="";
 $media_flag="N";
 $topicid = $_POST['topicid'];
 $userid = $_POST['userid'];
 $message = addslashes($_POST['message']);
 $embedded_content = $_POST['embedded_content'];
 $embedded_flag = $_POST['embedded_flag'];
 $token = $headers['Token'];
 if ($token==""){
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
}
 if(isset($_FILES["avatar"]))
 {
         foreach($_FILES['avatar']['name'] as $key=>$val)
         {
             $filename = $_FILES["avatar"]["name"][$key]; 
             $url_images[]=s3upload($key);
         }
         $List = implode(', ', $url_images); 
         $media_content=$List;
         $media_flag="Y";
 } 
 
if (!$topicid || $topicid == ""|| !$userid || $userid == "" || !$message || $message==""){
	$response = "{\"status\": \"error\"}";
	die($response);
}
else{
    $q = "CALL newPostwithmedia(\"$topicid\", \"$userid\",\"$message\",\"$embedded_content\",\"$embedded_flag\",\"$media_content\", \"$media_flag\");";
	$result = mysqli_query($db,$q);
	if($result == TRUE){
		$response = "{\"status\": \"success\"}";
	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}