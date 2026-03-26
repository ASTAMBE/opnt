<?php
           include ('dbconnection.inc');
   
           $username = $_GET['username'];
           $password = $_GET['password'];
           $password_question = $_GET['password_question'];
           $password_answer = $_GET['password_answer'];
           $country_code = $_GET['country_code'];
           if (!$username || $username == "" ||
                   !$password || $password == ""||
                  !$password_question || $password_question == ""||
                  !$password_answer || $password_answer == ""||
		!$country_code || $country_code == ""){
                   $response = "{\"status\": \"error\"}";
                  die($response);
           }
          else{
                  $q = "INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, CREATION_DATE, PASSWORD_Q, PASSWORD_Q_A, P_Q_CHANGE_DT, COUNTRY_CODE,FB_USER_FLAG) VALUES (\"$username\", AES_ENCRYPT(\"$password\", '290317'), NOW(), \"$password_question\", \"$password_answer\", NOW(), \"$country_code\",'N')" ;
                  $result = mysqli_query($db,$q);
//                echo $q;        
                if ($result == TRUE) {
                          $response = "{\"status\": \"success\"}";
                   }
                  else{
                          $response = "{\"status\": \"error\"}";
                  }
                  echo $response;
          }
  
  
  ?>
