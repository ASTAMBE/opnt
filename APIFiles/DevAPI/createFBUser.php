<?php

include('includeHeader.inc.php');



 $username = $postData['username'];
 $country_code = $postData['country_code'];
 $fb_username = $postData['fb_username'];
 $fb_userid = $postData['fb_userid'];


 if(!$username || $username == "" ||
      !$country_code || $country_code == ""){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
       
        $q = "call createFBUser(\"$username\", \"$country_code\", \"$fb_username\", \"$fb_userid\");";

        $result = mysqli_query($db,$q);
//                  echo $q;        
      if ($result == TRUE) {
                $response = "{\"status\": \"success\"}";
         }
        else{
                $response = "{\"status\": \"error\"}";
        }
        echo $response;
}

  
    ?>
