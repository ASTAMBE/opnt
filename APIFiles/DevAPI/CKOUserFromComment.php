<?php
include('includeHeader.inc.php');



	$userid = $postData['userid'];
	$postid = $postData['postid'];
	$commentid = $postData['commentid'];
	
	
	if (!$userid || $userid == "" || !$postid || $postid == ""
	|| !$commentid || $commentid==""){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{

		$q = "CALL CKOUserInsertDeleteQbyUID(\"$userid\",\"$postid\",\"$commentid\");";
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