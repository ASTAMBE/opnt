<?php
 require __DIR__ . '/s3/s3.php';
 include('includeHeader.inc.php');
 

 $url_images= array();
 $List="";
 $media_content="";
 $media_flag="N";
 $post_id = $_POST['post_id'];
 $userid = $_POST['userid'];
 $message = addslashes($_POST['message']);
 $embedded_content = $_POST['embedded_content'];
 $embedded_flag = $_POST['embedded_flag'];
 $postor_country_code = $_POST['country_code'];
 

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

 
if (!$post_id || $post_id == ""|| !$userid || $userid == "" || !$message || $message==""){
	$response = "{\"status\": \"error\"}";
	die($response);
}
else{
    $q = "CALL updatePost(\"$userid\",\"$post_id\",\"$message\",\"$embedded_content\",\"$embedded_flag\",\"$media_content\", \"$media_flag\");";
	$result = mysqli_query($db,$q);
	if($result == TRUE){
		$response = "{\"status\": \"success\"}";

	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}