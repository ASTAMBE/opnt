<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$parentpostid = $postData['parentpostid'];
	$postOnPostContent = $postData['postOnPostContent'];
	$emb_content = $postData['emb_content'];
	$emb_flag = $postData['emb_flag'];
	


	if (!$uuid || $uuid == "" ||!$parentpostid || $parentpostid=="" || !$postOnPostContent || $postOnPostContent=="" || $emb_flag=="" || !$emb_flag ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		
		$q = "CALL newThreadPostonPost(\"$uuid\",\"$parentpostid\",\"$postOnPostContent\",\"$emb_content\",\"$emb_flag\");";
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
