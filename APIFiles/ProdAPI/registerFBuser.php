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
  
        $q = "call createFBUserTokenApp(\"$username\", \"$country_code\", \"$fb_username\", \"$fb_userid\", \"$device_serial\",\"$dp_url\");";
        $result = mysqli_query($db,$q);
        //echo $q;        
      if ($result == TRUE) {
        $json_arry=array();
        $val =array("status"=>"success");
        $json1['status'] =  $val['status'];
        while (($row2 = mysqli_fetch_assoc($result))){
            array_push($json_arry, $row2); 	
            } 
        http_response_code(200);
        $data['data']= $json_arry;
        $array3 = array_merge($json1, $data);
        print json_encode($array3);
      }
        else{
         echo  $response = "{\"status\": \"Username Exists\"}";
        }
     
}

?>
