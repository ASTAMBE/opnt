<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

         $fromIndex ="";
         $toIndex =""; 
	$userid = $postData['userid'];
	$topicid = $postData['topicid'];
	$sortOrder = $postData['sortOrder'];
	$token = $headers['Token'];

	if(isset($postData['fromIndex'])){
		$fromIndex = $postData['fromIndex'];
		}
		if(isset($postData['toIndex'])){
		$toIndex = $postData['toIndex'];
		}

	if (!$userid || $userid == "" ||!$topicid || $topicid == "" ||!$sortOrder || $sortOrder == "" || $token == ""){
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
	 }
	else{
		if ($fromIndex == ""){
			$fromIndex = 0;
		}
		if ($toIndex == ""){
			$toIndex = 20;
		}
		if($verify=verify_jwt_by_userid($token,$userid)){

		}else{
					$response =array("status"=>"Authentication Failed");
					http_response_code(401);
					print json_encode($response);
					die();
		}
		$json_arry = array();
		$q = "CALL getUserCarts(\"$topicid\",\"$userid\",\"$sortOrder\",\"$fromIndex\",\"$toIndex\");";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			$val =array("status"=>"success");
			$json1['status'] =  $val['status'];
			while (($row = mysqli_fetch_assoc($result))){
                    $json['USERID'] = $row['USERID'];
                    $json['TOPICID'] =  $row['TOPICID'];
                    $cart="";
                    if(is_null($row['CART'])){
                       $cart="";
                    }else{
                        $cart=$row['CART'];
                    }
                    $json['CART'] = $cart;
                    $json['KEYID'] = $row['KEYID'];
                    $json['KEYWORDS'] =$row['KEYWORDS'];
                    $json['SRC'] =$row['SRC'];
                    $json['SORTER'] =$row['SORTER'];
					$json['COUNTRY_CODE'] =$row['COUNTRY_CODE'];
					$json['HCNT'] =$row['HCNT'];
					$json['LCNT'] =$row['LCNT'];
				array_push($json_arry, $json); 	
			 } 
			http_response_code(200);
			$data['data']= $json_arry;
			$array3 = array_merge($json1, $data);
			print json_encode($array3);
		}
		else{
 		 $response =array("status"=>"error");
 		 http_response_code(500);
 		 print json_encode($response);
		}
}
?>
