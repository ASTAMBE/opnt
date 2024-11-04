<?php
include('includeHeader.inc.php');

$device_uuid = $postData['device_uuid'];
$device_token = $postData['device_token'];

if (!$device_uuid || $device_uuid == ""|| !$device_token || $device_token == ""){
	$response = "{\"status\": \"invalid parameters error\"}";
	die($response);
}
else{
//saveDeviceToken(UID varchar(45), dtoken varchar(200))
	$q = "CALL saveDeviceToken(\"$device_uuid\", \"$device_token\");";
	$result = mysqli_query($db,$q);

	//echo $device_token;
	//echo $device_uuid;

	if($result == TRUE){
		$response = "{\"status\": \"success\"}";

	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}

?>




