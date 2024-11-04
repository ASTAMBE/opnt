<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

	$guestuuid = $postData['guestuuid'];
	$newUName = $postData['newUName'];
	$userid = $postData['userid'];
	$username = $postData['username'];
	$dp_url = $postData['dp_url'];  
	$convert_type = $postData['convert_type']; 

	if (!$guestuuid || $guestuuid == "" || !$newUName || $newUName == ""  || !$userid || $userid == "" || !$convert_type || $convert_type == ""){
 		 $response =array("status"=>"error");
 		 $json_arry[] =  $response;
 		echo $r =  json_encode($json_arry);
 	 
	 }

	else{
		$q = "CALL convertGuestUserAppNew(\"$guestuuid\",\"$newUName\",\"$username\",\"$userid\",\"$dp_url\",\"$convert_type\") ;";
		$result = mysqli_query($db,$q);
		 
		if($result == TRUE)
		{
			// while (($row = mysqli_fetch_assoc($result)))
			//     {
			// 	    if($row['status']=='error'){
			// 	    	$val =array("message"=>"error");
			// 	    	$json_arry[] =  $val;
			// 	    	$r =  json_encode($val);
			//             echo $r;
			// 	    }else{
			// 			$starttime= time();
			// 			$exptime = time()+ (14 * 24 * 60 * 60);
			// 			$token_payload = [
			// 			'uuid' => $row['USERID'],
			// 			'username' => $row['USERNAME'],
			// 			'country_code' => $row['COUNTRY_CODE'],
			// 			"iat" => $starttime,
			// 			"exp" => $exptime
			// 			];
			// 			$jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
			// 			$row['token']=$jwt;
            //             $json_arry['message'] =  "success";
			// 		    $json_arry['data'] =  $row;	
			// 		    $r =  json_encode($json_arry);
			//             echo $r;
			// 	    }
			// 	}
			while (($row = mysqli_fetch_assoc($result))){
				if(isset($row['existFlag']) && $row['existFlag'] == "YES"){
					$json_arry['message'] = "user exist";
				}
				else{
					$starttime= time();
					$exptime = time()+ (14 * 24 * 60 * 60);
					$token_payload = [
					'uuid' => $row['USERID'],
					'username' => $row['USERNAME'],
					'country_code' => $row['COUNTRY_CODE'],
					"iat" => $starttime,
					"exp" => $exptime
					];
					$jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
					$row['token']=$jwt;
					$json_arry['message'] =  "success";
					$json_arry['data'] =  $row;	
				}
			}
			$r =  json_encode($json_arry);
			echo $r;
		}
		else{
			$response =array("status"=>"Guest Username Exists");
			 $json_arry[] =  $response;
 		   echo $r =  json_encode($json_arry);
		}
}
?>
