<?php

include('includeHeader.inc.php');



$username = $postData['username'];
$password = $postData['password'];
$password_question = $postData['password_question'];
$password_answer = $postData['password_answer'];
$country_code = $postData['country_code'];


if (!$username || $username == "" ||
       !$password || $password == ""||
      !$password_question || $password_question == ""||
      !$password_answer || $password_answer == ""||
!$country_code || $country_code == ""){
       $response = "{\"status\": \"error\"}";
      die($response);
}
else{
      
      //$q = "INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, CREATION_DATE, PASSWORD_Q, PASSWORD_Q_A, P_Q_CHANGE_DT, COUNTRY_CODE,FB_USER_FLAG) VALUES (\"$username\", AES_ENCRYPT(\"$password\", '290317'), NOW(), \"$password_question\", \"$password_answer\", NOW(), \"$country_code\",'N')" ;
      $q = "call createNewUserWithCountry(\"$username\", \"$password\", \"$password_question\", \"$password_answer\", \"$country_code\");";

      $result = mysqli_query($db,$q);
//                echo $q;        
    if ($result == TRUE) {
              $response = "{\"status\": \"success\"}";
       }
      else{
              $response = "{\"status\": \"Error / Username Already Exists\"}";
      }
      echo $response;
}


?>
