<?php
   
   include('includeHeader.inc.php');

 $username = $_REQUEST['username'];
 $country_code = $_REQUEST['country_code'];
 $Google_userid = $_REQUEST['Google_userid'];
 $device_serial = $_REQUEST['device_serial'];
 $dp_url = $_REQUEST['dp_url'];
  
  if (!$username || $username == "" || !$country_code || $country_code == "" || !$Google_userid || $Google_userid == "" || !$device_serial || $device_serial == "" || !$dp_url || $dp_url == ""){
    $rtn = array ("status"=> "422","message"=>  "Unprocessable Entity");
        http_response_code(422);
        print json_encode($rtn);   
  }
  else{
     echo  $q = "CALL LoginGoogleUserApp(\"$username\", \"$country_code\",\"$dp_url\",\"$Google_userid\",\"$device_serial\");";

     $result = mysqli_query($db,$q);
    if($result == TRUE){
    	 $row = $result -> fetch_row();
    	http_response_code(200);
        print json_encode($row); 
    }else{
    	$response ="{\"status\": \"Google User Exists\"}";
    	http_response_code(500);
        print json_encode($response); 
    }

  }
  ?>
