<?php
 
	require_once('PushNotifications.php');
  	echo "ios push notifications arry";
	foreach ($ios_arry as $row) {

    		$deviceToken = $row['APP_TOKEN'];
    		$count = $row['PUSHCOUNT'];
  		$msg_payload = array (
                	'mtitle' => 'New Member added',
                 	'mdesc' => 'Hello',
  			'count' => count
        	 );
         }
        PushNotifications::iOS($msg_payload, $deviceToken);
  
  ?>
