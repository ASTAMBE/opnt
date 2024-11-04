<?php

    include('includeHeader.inc.php');

    require_once('PushNotifications.php');

	// Message payload
	$msg_payload = array (
		'mtitle' => 'Test push notification title',
		'mdesc' => 'Test push notification body',
		'count' => '2'
	);
	
	$deviceToken = $postData['device_token'];

    PushNotifications::iOS($msg_payload, $deviceToken);

?>

