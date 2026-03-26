<?php
    include('../../config.dev/dbconnection.inc');
    include('../../config.dev/util.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: 57P79st3f8uNaG359hB2109vwIE0lx2k");

    require_once('PushNotifications.php');
    require_once('AndroidPushNotifications.php');

    $ios_arry = array();
    $android_arry = array();
    $q = "CALL getPushNotifs();";
    $result = mysqli_query($db,$q);
    if($result == TRUE){
        while (($row = mysqli_fetch_assoc($result))){
            if ($row['LAST_USED_PLATFORM'] == 'ios'){     
                $deviceToken        = $row['APP_TOKEN'];
                $count              = $row['PUSHCOUNT'];
                $message            = $row['PUSH_TOPIC'];
                $pushType           = strtolower($row['PUSH_TYPE']);
                $sourceId           = $row['SOURCE_ID'];
                $pushTitle          = $row['PUSH_TITLE'];
                $userName           = $row['USERNAME'];
                if($pushType == 'conc'){
                    $pushType = 'comment';
                }
                $msg_payload        =   array (
                        'mtitle'        =>    $count.' '.$pushTitle,
                        'mdesc'         =>    $message,
                        'count'         =>    (int)$count,
                        'pushType'      =>    $pushType,
                        'sourceId'      =>    $sourceId,
                        'username'      =>    $userName,
                );
                PushNotifications::iOS($msg_payload, $deviceToken);       
            }	
            else if ($row['LAST_USED_PLATFORM'] == 'android'){
                $deviceToken        = $row['APP_TOKEN'];
                $count              = $row['PUSHCOUNT'];
                $message            = $row['PUSH_TOPIC'];
                $pushType           = strtolower($row['PUSH_TYPE']);
                $sourceId           = $row['SOURCE_ID'];
                $pushTitle          = $row['PUSH_TITLE'];
                $userName           = $row['USERNAME'];
                if($pushType == 'conc'){
                    $pushType = 'comment';
                }
                $fcmMsg = array();
                $fcmMsg['notification']    = array (
                                    'title'        =>    $count.' '.$pushTitle,
                                    'body'          =>    $message,
                                    'click_action'  =>    $pushType
                );
                $fcmMsg['data']    = array (
                                    'type'          =>    $pushType,
                                    'sourceId'      =>    $sourceId,
                                    'username'      =>    $userName,
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
