<?php
 require __DIR__ . '/s3/s3.php';
 include('includeHeader.inc.php');



 $url_images= array();
 $List="";
 $media_content="";
 $media_flag="N";

 $commentid = $_POST['commentid'];
 $userid = $_POST['userid'];
 $comments = addslashes($_POST['comments']);
 $embedded_content = $_POST['embedded_content'];
 $embedded_flag = $_POST['embedded_flag'];
 



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
 

if (!$commentid || $commentid == ""|| !$userid || $userid == ""){
	$response = "{\"status\": \"errors\"}";
	die($response);
}
else{
    $q = "CALL editCommentNew(\"$userid\",\"$commentid\",\"$comments\",\"$embedded_content\",\"$embedded_flag\",\"$media_content\", \"$media_flag\");";
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