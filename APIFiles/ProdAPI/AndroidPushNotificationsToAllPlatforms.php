<?php
   
   include('includeHeader.inc.php'); 
   require_once('AndroidPushNotifications.php');
   
    $ios_arry = array();
    $android_arry = array();
    $q = "CALL getPushNotifs();";
    $result = mysqli_query($db,$q);
  
  
    if($result == TRUE){

      while (($row = mysqli_fetch_assoc($result))){
        
		if ($row['LAST_USED_PLATFORM'] == 'android'){       	

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
