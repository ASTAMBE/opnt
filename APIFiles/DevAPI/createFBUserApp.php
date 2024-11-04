<?php

include('includeHeader.inc.php');


 $username = $postData['username'];
 $country_code = $postData['country_code'];
 $fb_username = $postData['fb_username'];
 $fb_userid = $postData['fb_userid'];
 $device_serial = $postData['device_serial'];
 $dp_url = $postData['dp_url'];
 

//Added url optional ;
 if (!$username || $username == "" ||
      !$country_code || $country_code == "" ||
      !$device_serial || $device_serial == "" ) {
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
      
        $q = "call createFBUserApp(\"$username\", \"$country_code\", \"$fb_username\", \"$fb_userid\", \"$device_serial\",\"$dp_url\");";

        $result = mysqli_query($db,$q);
        //echo $q;        
      if ($result == TRUE) {
                $response = "{\"status\": \"success\"}";
         }
        else{
            //    $response = "{\"status\": \"error\"}";
           $response = "{\"status\": \"Username Exists\"}";
        }
        echo $response;
}

?>
