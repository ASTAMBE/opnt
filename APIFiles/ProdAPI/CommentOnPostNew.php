<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
 require __DIR__ . '/s3/s3.php';
 include('jwt_verify.php');
 include('sendNotification.php');

 $url_images= array();
 $List="";
 $media_content="";
 $media_flag="N";
 $causePostID = $_POST['causePostID'];
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

if (!$commentUUID || $commentUUID == "" || !$causePostID || $causePostID=="" ||
!$embedded_flag || $embedded_flag == ""){
	$response = "{\"status\": \"error\"}";
	die($response);
}
else{
    $q = "CALL newCommentOnPost(\"$commentUUID\",\"$causePostID\",\"$commentContent\",\"$embedded_content\",\"$embedded_flag\",
     \"$media_content\", \"$media_flag\");";
	$result = mysqli_query($db,$q);
	if($result == TRUE){
		$response = "{\"status\": \"success\"}";

        $check = "SELECT USER.IDENTIFIER_TOKEN, USER.USERNAME, TPC.TOPICID, TPC.TOPIC FROM OPN_POSTS POST JOIN OPN_TOPICS TPC ON TPC.TOPICID = POST.TOPICID JOIN OPN_USERLIST USER ON USER.USERID = POST.POST_BY_USERID WHERE POST.POST_ID = ".$causePostID." AND USER.USER_UUID != \"$commentUUID\"";
        $getData = mysqli_query($db, $check);
        $row = $getData -> fetch_assoc();

        if ($getData == TRUE && !empty($row['IDENTIFIER_TOKEN'])) {
            $msg = array (
                'title' => '1 New comment on your post in '.$row['TOPIC'],
                'action' => 'comment',
                'data' => array(
                    'post_id' => $causePostID,
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