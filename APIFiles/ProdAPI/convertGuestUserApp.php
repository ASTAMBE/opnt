<?php

include('includeHeader.inc.php');

	$guestuuid = $postData['guestuuid'];
	$newUName = $postData['newUName'];
	$newPwd = $postData['newPwd'];
	$newPwdQ = $postData['newPwdQ'];
	$newPQAnswer = $postData['newPQAnswer'];
	$device_serial = $postData['device_serial'];   

	if (!$guestuuid || $guestuuid == "" || !$newUName || $newUName == "" || !$newPwd || $newPwd == "" || !$newPwdQ || $newPwdQ == "" || !$newPQAnswer || $newPQAnswer == "" || !$device_serial || $device_serial == "" ){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
		$q = "CALL convertGuestUserApp(\"$guestuuid\",\"$newUName\",\"$newPwd\",\"$newPwdQ\"
		,\"$newPQAnswer\", \"$device_serial\") ;";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			while (($row = mysqli_fetch_assoc($result))){
					$json_arry[] =  $row;
			 }
			$r =  json_encode($json_arry);
			echo $r;
		}
		else{
		//	$response = "{\"status\": \"error\"}";
			$response = "{\"status\": \"Guest Username Exists\"}";
			echo $response;
		}
}
?>
