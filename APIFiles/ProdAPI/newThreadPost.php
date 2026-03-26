<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$threadid = $postData['threadid'];
	$threadpost = $postData['threadpost'];
	$emb_flag = $postData['emb_flag'];
	
	
	if (!$uuid || $uuid == "" || !$threadid || $threadid == ""
	|| !$threadpost || $threadpost=="" || $emb_flag=="" || !$emb_flag ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		$q = "CALL newThreadPost(\"$uuid\",\"$threadid\",\"$threadpost\",\"$emb_content\",\"$emb_flag\");";
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