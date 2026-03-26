<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$parentpostid = $postData['parentpostid'];
	$threadComment = $postData['threadComment'];
	$emb_flag = $postData['emb_flag'];
	

	if (!$uuid || $uuid == "" || !$threadid || $threadid == ""
	|| !$parentpostid || $parentpostid=="" || $emb_flag=="" || !$emb_flag){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		$q = "CALL newThreadComment(\"$uuid\",\"$parentpostid\",\"$threadComment\",\"$emb_content\",\"$emb_flag\");";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			$response =array("status"=>"success");
			http_response_code(200);
			print json_encode($response);
		}
		else{
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
		}
}
?>
