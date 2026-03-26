<?php

include('includeHeader.inc.php');


$username = $postData['username'];


if (!$username || $username == "" ){
        $response = "{\"status\": \"error\"}";
      die($response);

}
else{


		$json_arry = array();
		$q = "CALL getuseractivity(\"$username\")";
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
 		 $json_arry[] =  $response;
 		 http_response_code(500);
 		 print json_encode($json_arry);
		}
}




?>
