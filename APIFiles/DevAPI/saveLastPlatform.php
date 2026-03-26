<?php
include('includeHeader.inc.php');

$device_uuid = $postData['device_uuid'];
$platform = $postData['platform'];

if (!$device_uuid || $device_uuid == ""|| !$platform || $platform == ""){
	$response = "{\"status\": \"invalid parameters error\"}";
	die($response);
}
else{
//saveLastPlatform(UID varchar(45), LASTPLTFRM varchar(100))
	$q = "CALL saveLastPlatform(\"$device_uuid\", \"$platform\");";
	$result = mysqli_query($db,$q);

	if($result == TRUE){
		$response = "{\"status\": \"success\"}";

	}
	else{
		$response = "{\"status\": \"error\"}";
	}
	echo $response;
}

?>




