<?php
   include('includeHeader.inc.php');   
  // include('includeHeader.inc.php'); 
   require_once('PushNotifications.php');
   require_once('AndroidPushNotifications.php');


   
    $ios_arry = array();
    $android_arry = array();
    $q = "CALL getPushNotifs();";
    $result = mysqli_query($db,$q);
  
    //$json_arry = array();

    if($result == TRUE){

       while (($row = mysqli_fetch_assoc($result))){
        
        if ($row['LAST_USED_PLATFORM'] == 'ios'){       	

		    	 $deviceToken = $row['APP_TOKEN'];
            $count = $row['PUSHCOUNT'];
			     $message = $row['PUSH_TOPIC'];
            $msg_payload = array (
              'mtitle' => $count.' new post/s added in',
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
                'title' => $count.' new post/s added in',
                'body' => $message
              );

             AndroidPushNotifications::Send($fcmMsg, $deviceToken);
       	}
        //$json_arry[] =  $row;
       
      }

      //$r =  json_encode($json_arry);
      // echo $r;
    }
    else{
		  $response = "{\"status\": \"error\"}";
		  echo $response;
	 }
	
   
 ?>
