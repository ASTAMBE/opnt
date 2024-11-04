<?php

include('includeHeader.inc.php');

	$username = $postData['username'];
	$pwd = $postData['password'];
	 $device_serial = $postData['device_serial'];   

// removed the initial validity check for the input values 
//	 if (!$username || $username == ""|| !$pwd || $pwd == "" || !$device_serial || $device_serial == "" ){
	// 		 if (!$username || $username == ""|| !$device_serial || $device_serial == "" ){

	//	if (!$username || $username == ""|| !$password || $password == ""  ){
 //		 $response = "{\"status\": \"First problem\"}";
 //	 	die($response);
//	 }
//	else{
		//$q = "CALL userLoginApp(\"$username\",   \"$device_serial\") ;";

	 // general comment //new
		 $q = "CALL userLoginApp(\"$username\",  \"$pwd\" ,   \"$device_serial\") ;";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			while (($row = mysqli_fetch_assoc($result))){
					$json_arry[] =  $row;
			 }
			$r =  json_encode($json_arry);
			echo $r;
		}
		else{
			$response = "{\"status\": \"No Record Found\"}";
			echo $response;
		}
//}
?>
