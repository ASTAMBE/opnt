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

		$check = "SELECT USER.IDENTIFIER_TOKEN, USER.USERNAME, TPC.TOPICID, TPC.TOPIC, OPC.CAUSE_POST_ID FROM OPN_POST_COMMENTS OPC JOIN OPN_TOPICS TPC ON TPC.TOPICID = OPC.TOPICID JOIN OPN_USERLIST USER ON USER.USERID = OPC.POST_BY_USERID WHERE OPC.COMMENT_ID = ".$causeCommentId." AND USER.USER_UUID != \"$commentUUID\"";
        $getData = mysqli_query($db, $check);
        $row = $getData -> fetch_assoc();

        if ($getData == TRUE && !empty($row['IDENTIFIER_TOKEN'])) {
            $msg = array (
                'title' => '1 New comment on your post in '.$row['TOPIC'],
                'action' => 'comment',
                'data' => array(
                    'post_id' => $row['CAUSE_POST_ID'],
                    'comment_id' => $causeCommentId,
                    'topic_id' => $row['TOPICID'],
                    'username' => $row['USERNAME'],
                )
            );

            sendNotification($db, array( $row['IDENTIFIER_TOKEN'] ), $msg);

        }

	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}