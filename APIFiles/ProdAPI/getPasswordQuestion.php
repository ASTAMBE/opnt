<?php

include('includeHeader.inc.php');


$username = $postData['username'];


//if (!$userid || $userid == ""){
if (!$username || $username == "" ){
        $response = "{\"status\": \"error\"}";
      die($response);
}
else{

  
//$q = "SELECT PASSWORD_Q  FROM OPN_USERLIST WHERE USERNAME = \"$userid\";";

 $q = "call getPasswordQuestion(\"$username\");";


$result = mysqli_query($db,$q);
      if($result == TRUE){
      
while (($row = mysqli_fetch_assoc($result))){
      
$json_arry[] =  $row;
       }
      $r =  json_encode($json_arry);
     echo $r;
      }
     else{
      $response = "{\"status\": \"error\"}";
     echo $r;
      }
}


?>
