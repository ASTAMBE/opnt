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
 $causeCommentId = $_POST['causeCommentId'];
 $commentUUID = $_POST['userid'];
 $commentContent = addslashes($_POST['commentContent']);
 $embedded_content = $_POST['embedded_content'];
 $embedded_flag = $_POST['embedded_flag'];
 $token = $headers['Token'];
 if ($token==""){
	$response =array("status"=>"error");
	http_response_code(500);
	print json_encode($response);
}
else{

  if($verify=verify_jwt_by_userid($token,$commentUUID)){

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
 
if (!$commentUUID || $commentUUID == "" || !$causeCommentId || $causeCommentId=="" ||
!$embedded_flag || $embedded_flag == ""){
	$response = "{\"status\": \"error\"}";
	die($response);
}
else{
    $q = "CALL newCommentOnComment(\"$commentUUID\",\"$causeCommentId\",\"$commentContent\",\"$embedded_content\",\"$embedded_flag\",
     \"$media_content\", \"$media_flag\");";
	$result = mysqli_query($db,$q);
	if($result == TRUE){
		$response = "{\"status\": \"success\"}";
	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}