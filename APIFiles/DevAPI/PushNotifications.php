<?php 
// Server file
class PushNotifications {

	// (iOS) Private key's passphrase.
	private static $passphrase = 'AntinoDev';
	
	// Change the above three vriables as per your app.
	//echo "ios push notifiations test";
	public function __construct() {
		exit('Init function is not allowed');
	}
	
    // Sends Push notification for iOS users
	// public function iOS($data, $devicetoken) {

	// 	$deviceToken = $devicetoken;
	// 	//pushcert.pem
	// 	//$pushcertPath = 'production.pem';
	// 	// $pushcertPath = 'opinitodevpush.pem';
	// 	$pushcertPath = dirname(__FILE__).'OpinitoTestDev.pem';

	// 	$ctx = stream_context_create();
	// 	// ck.pem is your certificate file
	// 	stream_context_set_option($ctx, 'ssl', 'local_cert', $pushcertPath);
	// 	stream_context_set_option($ctx, 'ssl', 'passphrase', self::$passphrase);

	// 	// Open a connection to the APNS server
	// 	$fp = stream_socket_client(
	// 		'ssl://gateway.sandbox.push.apple.com:2195', $err,
	// 		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

	// 	if (!$fp)
	// 		exit("Failed to connect: $err $errstr" . PHP_EOL);

	// 	// Create the payload body
	// 	$body['aps'] = array(
	// 		'alert' => array(
	// 		    'title' => $data['mtitle'],
    //             'body' => $data['mdesc'],
	// 		 ),
	// 		 'data' => array(
	// 			'type'		=>	$data['pushType'],
	// 			'sourceId'	=>	$data['sourceId'],
	// 			'username'	=>	$data['username'],
	// 		),
	// 		'sound' => 'default',
	// 		'badge' => $data['count']
	// 	);

	// 	// Encode the payload as JSON
	// 	$payload = json_encode($body);
	// 	echo $payload;
	// 	// Build the binary notification
	// 	$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

	// 	// Send it to the server
	// 	$result = fwrite($fp, $msg, strlen($msg));
		
	// 	// Close the connection to the server
	// 	fclose($fp);

	// 	if (!$result)
	// 		return 'Message not delivered' . PHP_EOL;
	// 	else
	// 		return 'Message successfully delivered' . PHP_EOL;

	// }

	public function iOS($data, $devicetoken) {
		
		$notification = array(
			'title' => $data['mtitle'],
			'body' => $data['mdesc'],
			'click_action' => $data['pushType'],
		);
		
		$addData = array(
			'type'		=>	$data['pushType'],
			'sourceId'	=>	$data['sourceId'],
			'username'	=>	$data['username'],
		);

		$fcmFields = array(
			'registration_ids' => array($devicetoken),//"dO3b27Atpuo:APA91bESLyDN9QwiGt_JQGY1a_e48k-7o_hjsBtAcqS8v0FwI2mEiZ_TQk7lMwwKKSELV5W_X3YNw3bq-rWVLEVmCBLM-9OazQ3sv06gA1Z7gEJvCR_nk4oruZBdGIFd2eF4cwAbPLJD",
        	'priority' => 'high',
			'notification' => $notification,
			'data' => $addData,
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
