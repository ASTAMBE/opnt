<?php

include('includeHeader.inc.php');


	$uuid = $postData['uuid'];
	$tid = $postData['tid'];
	$threadhead = $postData['threadhead'];
	$threadpost = $postData['threadpost'];
	$embedded_content = $postData['embedded_content'];
	$embedded_flag = $postData['embedded_flag'];
	


	if (!$uuid || $uuid == "" || !$tid || $tid == "" || !$threadhead || $threadhead == "" || !$threadpost || $threadpost == "" || !$embedded_flag || $embedded_flag == ""  ){
 		 $response =array("status"=>"error");
 		 $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($json_arry);
	 }

	else{
		
		$q = "CALL newThread(\"$tid\",\"$uuid\",\"$threadhead\",\"$threadpost\",\"$embedded_content\",\"$embedded_flag\");";
		$result = mysqli_query($db,$q);
		 
		if($result == TRUE){
			$val =array("status"=>"success");
			$json_arry['status'] =  $val['status'];

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
