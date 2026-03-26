<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$threadPostid = $postData['threadPostid'];
	$userAction = $postData['userAction'];
	

	if (!$uuid || $uuid == "" || !$threadPostid || $threadPostid == "" || !$userAction || $userAction=="" ){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{

		
		$q = "CALL loveOrHateThreadPost(\"$uuid\",\"$threadPostid\",\"$userAction\");";
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
