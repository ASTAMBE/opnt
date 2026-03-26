<?php

    // include('includeHeader.inc.php');
	
	// $data = array (
    //     'title' => '1 New comment on your post in topic name',
    //     'action' => 'comment'
    // );
	
    function sendNotification ($db, $deviceTokens, $data) {

        $fields = array (
            'registration_ids' => $deviceTokens,
            'notification' => array(
                'title' => $data['title'],
                'click_action' => $data['action']
            ),
            'data' => $data['data']
        );

        $headers = array (
            'Authorization: key=AAAAKpQVMkM:APA91bFFs3A98AMnh5IKzmHwenGExAcoyCW4dVVBd8Z-NfqwhBIAHUS_Fk2vBYQYUzEdfXAqgo1JliSeeNWTZNhlFXjIq3_HKUGi-DtpnFLmjQMAVroebTvioZTNwrbPk-pu5CqAJolM',
            'Content-Type: application/json'
        );

        $ch = curl_init();
        curl_setopt( $ch,CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send' );
        curl_setopt( $ch,CURLOPT_POST, true );
        curl_setopt( $ch,CURLOPT_HTTPHEADER, $headers );
        curl_setopt( $ch,CURLOPT_RETURNTRANSFER, true );
        curl_setopt( $ch,CURLOPT_SSL_VERIFYPEER, false );
        curl_setopt( $ch,CURLOPT_POSTFIELDS, json_encode( $fields ) );
        $result = curl_exec($ch );
        curl_close( $ch );

    }

?>
