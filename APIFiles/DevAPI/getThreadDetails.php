<?php

include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$threadid = $postData['threadid'];
	$threadid1 = $postData['threadid1'];
	

	if (!$uuid || $uuid == "" || !$threadid || $threadid == ""  || !$threadid1 || $threadid1 == "" ){
 		 $response =array("status"=>"error");
 		 $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($json_arry);
	 }

	else{

	
		$q = "CALL getThreadDetails(\"$uuid\",\"$threadid\",\"$threadid1\");";
		$result = mysqli_query($db,$q);
		 
		if($result == TRUE){
			$val =array("status"=>"success");
			while (($row = mysqli_fetch_assoc($result))){
				    $json_arry['status'] =  $val['status'];
					$json_arry['data'] =  $row;	
			 }
			http_response_code(200);
			print json_encode($json_arry);
		}
		else{
 		 $response =array("status"=>"error");
 		 $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($json_arry);
		}
}
?>
