<?php
include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$tpostid = $postData['tpostid'];
	

	if (!$uuid || $uuid == "" || !$tpostid || $tpostid == "" ){
 		 $response =array("status"=>"error");
 		// $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		 $json_arry = array();
		$q = "CALL getThreadPostDetails(\"$uuid\",\"$tpostid\");";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			$val =array("status"=>"success");
			$json1['status'] =  $val['status'];
			while (($row = mysqli_fetch_assoc($result))){
				array_push($json_arry, $row); 	
			 } 
			http_response_code(200);
			$data['data']= $json_arry;
			$array3 = array_merge($json1, $data);
			print json_encode($array3);
		}
		else{
 		 $response =array("status"=>"error");
 		// $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($response);
		}
}
?>
