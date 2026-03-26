<?php
//include('includeHeader.inc.php');

class AndroidPushNotifications {
   
    // API access key from Google FCM App Console
	//private static $API_ACCESS_KEY = 'AAAAKpQVMkM:APA91bFFs3A98AMnh5IKzmHwenGExAcoyCW4dVVBd8Z-NfqwhBIAHUS_Fk2vBYQYUzEdfXAqgo1JliSeeNWTZNhlFXjIq3_HKUGi-DtpnFLmjQMAVroebTvioZTNwrbPk-pu5CqAJolM
//';
	//define( 'API_ACCESS_KEY', 'AAAAKpQVMkM:APA91bFFs3A98AMnh5IKzmHwenGExAcoyCW4dVVBd8Z-NfqwhBIAHUS_Fk2vBYQYUzEdfXAqgo1JliSeeNWTZNhlFXjIq3_HKUGi-DtpnFLmjQMAVroebTvioZTNwrbPk-pu5CqAJolM' );
	
	public function Send($data, $reg_id) {
		$singleID = $reg_id;
		$fcmMsg = $data;
		// $fcmMsg = array(
		// 'body' => 'here is a message. message',
		// 'title' => 'This is title #1',
		// );

		$fcmFields = array(
			'registration_ids' => array($singleID),//"dO3b27Atpuo:APA91bESLyDN9QwiGt_JQGY1a_e48k-7o_hjsBtAcqS8v0FwI2mEiZ_TQk7lMwwKKSELV5W_X3YNw3bq-rWVLEVmCBLM-9OazQ3sv06gA1Z7gEJvCR_nk4oruZBdGIFd2eF4cwAbPLJD",
        	'priority' => 'high',
			'notification' => $fcmMsg['notification'],
			'data' => $fcmMsg['data'],
		);
		//echo json_encode($fcmFields);die;
		$headers = array(
			'Authorization: key=AAAAKpQVMkM:APA91bFFs3A98AMnh5IKzmHwenGExAcoyCW4dVVBd8Z-NfqwhBIAHUS_Fk2vBYQYUzEdfXAqgo1JliSeeNWTZNhlFXjIq3_HKUGi-DtpnFLmjQMAVroebTvioZTNwrbPk-pu5CqAJolM',
			'Content-Type: application/json'
		);
 
		$ch = curl_init();
		curl_setopt( $ch,CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send' );
		curl_setopt( $ch,CURLOPT_POST, true );
		curl_setopt( $ch,CURLOPT_HTTPHEADER, $headers );
		curl_setopt( $ch,CURLOPT_RETURNTRANSFER, true );
		curl_setopt( $ch,CURLOPT_SSL_VERIFYPEER, false );
		curl_setopt( $ch,CURLOPT_POSTFIELDS, json_encode( $fcmFields ) );
		$result = curl_exec($ch );
		curl_close( $ch );
		echo $result . "\n\n";
	}
}
?>