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

		$sql = "SELECT POSTS.POST_ID FROM opntprod.OPN_POSTS_RAW POSTS JOIN opntprod.OPN_USERLIST USER ON USER.USERID = POSTS.POST_BY_USERID WHERE USER.USER_UUID = \"$userid\" ORDER BY POSTS.POST_ID DESC LIMIT 1";
        $getResult = mysqli_query($db, $sql);
		$postData = $getResult -> fetch_assoc();

		if($getResult == TRUE && !empty($postData['POST_ID'])){

			$check = "SELECT DISTINCT USER.IDENTIFIER_TOKEN, USER.USERNAME, TPC.TOPIC FROM OPN_USER_CARTS CART JOIN OPN_TOPICS TPC ON TPC.TOPICID = CART.TOPICID JOIN OPN_USERLIST USER ON USER.USERID = CART.USERID WHERE CART.TOPICID = ".$topicid." AND USER.USER_UUID != \"$userid\"";
			$getData = mysqli_query($db, $check);

			if($getData == TRUE){
				$deviceTokens = array();
				while (($row = mysqli_fetch_assoc($getData))){
					if (!empty($row['IDENTIFIER_TOKEN'])) {
						$msg = array (
							'title' => '1 New post added in '.$row['TOPIC'],
							'action' => 'post',
							'data' => array(
								'post_id' => $postData['POST_ID'],
								'topic_id' => $topicid,
								'username' => $row['USERNAME'],
							)
						);
						array_push($deviceTokens, $row['IDENTIFIER_TOKEN']);
					}
				}

				$deviceTokens = array_chunk(array_unique($deviceTokens), 1000);

				if (count($deviceTokens)) {
					foreach ($deviceTokens as $key => $value) {
						sendNotification($db, $value, $msg);
					}
				}

			}

		}

	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}