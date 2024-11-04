<?php 
// Server file
class PushNotifications {

	// (iOS) Private key's passphrase.
	//partha123
	private static $passphrase = 'AntinoProd';
	
	// Change the above three vriables as per your app.
	//echo "ios push notifiations test";
	public function __construct() {
		exit('Init function is not allowed');
	}
	
        // Sends Push notification for iOS users
	public function iOS($data, $devicetoken) {

		$deviceToken = $devicetoken;
		//pushcert.pem
		//$pushcertPath = 'production.pem';
		$pushcertPath = dirname(__FILE__).'/CertificatesProdPEM.pem';
		$ctx = stream_context_create();
		// ck.pem is your certificate file
		stream_context_set_option($ctx, 'ssl', 'local_cert', $pushcertPath);
		stream_context_set_option($ctx, 'ssl', 'passphrase', self::$passphrase);

		// Open a connection to the APNS server
		$fp = stream_socket_client(
			'ssl://gateway.push.apple.com:2195', $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);

		// Create the payload body
		$body['aps'] = array(
			'alert' => array(
			    'title' => $data['mtitle'],
                'body' => $data['mdesc'],
			 ),
			'sound' => 'default',
			'badge' => $data['count']
		);

		// Encode the payload as JSON
		$payload = json_encode($body);
		echo $payload;
		// Build the binary notification
		$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));
		
		// Close the connection to the server
		fclose($fp);

		if (!$result)
			return 'Message not delivered' . PHP_EOL;
		else
			return 'Message successfully delivered' . PHP_EOL;

	}
    
}
?>
