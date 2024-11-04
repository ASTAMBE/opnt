<?php
   
include('includeHeader.inc.php');


 $username = $postData['username'];
 $country_code = $postData['country_code'];
 $fname = $postData['fname'];
 $lname = $postData['lname'];
 $google_email = $postData['google_email'];
 $Google_username = $postData['Google_username'];
 $Google_userid = $postData['Google_userid'];
 $device_serial = $postData['device_serial'];
 $dp_url = $postData['dp_url'];
 
  
  if (!$username || $username == "" || !$country_code || $country_code == "" || !$device_serial || $device_serial == "" || !$fname || $fname == "" || !$lname || $lname == "" || !$google_email || $google_email == "" || !$Google_username || $Google_username == "" || !$Google_userid || $Google_userid == "" || !$device_serial || $device_serial == ""){
         $rtn = array ("status"=> "error");
          http_response_code(500);
          print json_encode($rtn);   
  }
  else{

  
     $q = "CALL createGoogleUserApp(\"$username\", \"$country_code\", \"$fname\", \"$lname\",\"$google_email\",\"$dp_url\",\"$Google_username\", \"$Google_userid\",\"$device_serial\");";

    $result = mysqli_query($db,$q);
    if($result == TRUE){
        $rtn = array ("status"=> "success");
        http_response_code(200);
        print json_encode($rtn); 
    }else{
        $rtn = array ("status"=> "Username Exists");
        http_response_code(500);
        print json_encode($rtn); 
    }
  }
  
  
  ?>