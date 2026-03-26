<?php

include('includeHeader.inc.php');

	$username = $postData['username'];
	$password = $postData['password'];
		$device_serial = $postData['device_serial'];   


	if (!$username || $username == ""|| !$password || $password == "" || !$device_serial || $device_serial == "" ){
 		 $response = "{\"status\": \"Wrong or No Inputs\"}";
 	 	die($response);
	 }
	else{
		$q = "CALL userLogin(\"$username\",  \"$password\") ;";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			while (($row = mysqli_fetch_assoc($result))){
					$json_arry[] =  $row;
			 }
			$r =  json_encode($json_arry);
			echo $r;
		}
		else{
			$response = "{\"status\": \"error\"}";
			echo $response;
		}
}
?>
