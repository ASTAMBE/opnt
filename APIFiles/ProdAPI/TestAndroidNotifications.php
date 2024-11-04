<?php

    include('includeHeader.inc.php');

    require_once('AndroidPushNotifications.php');

	// Message payload
	
	$fcmMsg = array (
        'title' => 'Partha new Test push notification title',
        'body' => 'Partha Test push notification body'
    );
	
	$deviceToken = 'fuZy7IOzRIKMbRW-MvVRnX:APA91bE0NDsJX22BZxcP1Ruixb8O2tmHRAKTUGvHvYb5DW0Crc7ESRgc-ZFak8FCBcdcoi3IP_Hj4zBYStSvskz8jiMhMyGXEWvPQ_eRvqUZL-cjFPuOu6cvHPC75Gtb5NTGPCw8o0Ro';
    AndroidPushNotifications::Send($fcmMsg, $deviceToken);

?>
