<?php

    require_once('AndroidPushNotifications.php');

	// For Android
	$regId = 'fuZy7IOzRIKMbRW-MvVRnX:APA91bE0NDsJX22BZxcP1Ruixb8O2tmHRAKTUGvHvYb5DW0Crc7ESRgc-ZFak8FCBcdcoi3IP_Hj4zBYStSvskz8jiMhMyGXEWvPQ_eRvqUZL-cjFPuOu6cvHPC75Gtb5NTGPCw8o0Ro';
	$fcmMsg = array (
                                'title' => '2 new post added in',
                                'body' => 'Parth test android push notifications'
                               
            		);
    AndroidPushNotifications::Send($fcmMsg, $regId);

?>

