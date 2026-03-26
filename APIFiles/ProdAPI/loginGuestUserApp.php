<?php
   
  include('includeHeader.inc.php');
  
 
  
  $postData = getPostData();
  
  $userid = $postData['userid'];
  $devicename = $postData['devicename'];
  $device_serial = $postData['device_serial'];   
  

  
  if (!$userid || $userid == "" || !$devicename || $devicename == "" || !$device_serial || $device_serial == "" ){
    $response = "{\"status\": \"error\"}";
    die($response);
  }
  else{
   
    $q = "CALL loginGuestUserApp(\"$devicename\", \"$userid\", \"$device_serial\");";
  
    $result = mysqli_query($db,$q);
    if($result == TRUE){
      while (($row = mysqli_fetch_assoc($result))){
        $json_arry[] =  $row;
      }
      if(isset($json_arry)){
        $r =  json_encode($json_arry);
        echo $r;
      }else{
       echo json_encode(array());
     }
  
   }
   else{
    $response = "{\"status\": \"error\"}";
    echo $response;
  }
  }
  
  
  ?>
