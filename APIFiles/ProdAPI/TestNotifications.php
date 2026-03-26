<?php

    include('includeHeader.inc.php');

    require_once('PushNotifications.php');

	// Message payload
	$msg_payload = array (
		'mtitle' => 'Test push notification title',
		'mdesc' => 'Test push notification body',
		'count' => '2'
	);
	
	$deviceToken = '681F8CAE1902CC31A6C07994E5BAC412555C4D83CEFA64BECE9B3D5245D00ED4';
    PushNotifications::iOS($msg_payload, $deviceToken);

?>
