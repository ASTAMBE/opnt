<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

	$userid = $postData['userid'];
    $postid = $postData['postid'];
    $sortOrder = $postData['sortOrder'];
	$fromIndex = $postData['fromIndex'];
	$toIndex = $postData['toIndex'];
	$token = $headers['Token'];

	 if(isset($postData['fromIndex'])){
	    $fromIndex = $postData['fromIndex'];
	    }else{
	         $fromIndex = 0;
	     }
     if(isset($postData['toIndex'])){
	    $toIndex = $postData['toIndex'];
		}else{
	         $toIndex = 20;
		}
	if (!$userid || $userid == "" || !$postid || $postid == "" || $token == ""){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response );
	 }
	else{

		if($verify=verify_jwt_by_userid($token,$userid)){

		}else{
					$response =array("status"=>"Authentication Failed");
					http_response_code(401);
					print json_encode($response);
					die();
		}

		 $json_arry = array();
		$q = "CALL commentsByPostNW(\"$postid\",\"$userid\",\"$sortOrder\",\"$fromIndex\",\"$toIndex\");";
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
 		 http_response_code(500);
 		 print json_encode($response );
		}
}
?>
