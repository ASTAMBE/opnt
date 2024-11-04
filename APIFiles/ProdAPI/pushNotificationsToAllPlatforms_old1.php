<?php
    include('../../config.prod/dbconnection.inc');
    include('../../config.prod/util.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: J.4O8SGQFNM%ZJR't8wX99y5a=X0/F");
 
    require_once('PushNotifications.php');
    require_once('AndroidPushNotifications.php');
    $ios_arry = array();
    $android_arry = array();
    $q = "CALL getPushNotifs();";
	$result = mysqli_query($db,$q);
	
    if($result == TRUE){
        while (($row = mysqli_fetch_assoc($result))){
			if ($row['LAST_USED_PLATFORM'] == 'ios'){       
				$deviceToken = $row['APP_TOKEN'];
				$count = $row['PUSHCOUNT'];
				$message = $row['PUSH_TOPIC'];
				$msg_payload = array (
					'mtitle' => $count.' new post added in',
					'mdesc' => $message,//'Hello',
					'count' =>(int)$count
				);
				PushNotifications::iOS($msg_payload, $deviceToken);       
			}	
			else if ($row['LAST_USED_PLATFORM'] == 'android'){
				$deviceToken = $row['APP_TOKEN'];
				$count = $row['PUSHCOUNT'];
				$message = $row['PUSH_TOPIC'];
				$fcmMsg = array (
					'title' => $count.' new post added in',
					'body' => $message
				);
				AndroidPushNotifications::Send($fcmMsg, $deviceToken);
			}
    	}
    }
    else{
		$response = "{\"status\": \"error\"}";
		echo $response;
	}
?>
