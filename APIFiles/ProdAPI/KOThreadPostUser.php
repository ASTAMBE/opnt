<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$threadid = $postData['threadid'];
	

	if (!$uuid || $uuid == "" || !$threadid || $threadid == "" ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		$q = "CALL KOThreadPostUser(\"$uuid\",\"$threadid\");";
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
