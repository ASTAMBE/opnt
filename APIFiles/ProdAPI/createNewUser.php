<?php

include('includeHeader.inc.php');



$username = $postData['username'];
$password = $postData['password'];
$password_question = $postData['password_question'];
$password_answer = $postData['password_answer']; 


if (!$username || $username == "" ||
        !$password || $password == ""||
        !$password_question || $password_question == ""||
        !$password_answer || $password_answer == ""){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
   
 	$q = "INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, CREATION_DATE, PASSWORD_Q, PASSWORD_Q_A, P_Q_CHANGE_DT) VALUES (\"$username\", \"$password\", CURRENT_DATE(), \"$password_question\", \"$password_answer\", CURRENT_DATE())" ;
	$result = mysqli_query($db,$q);
echo $q;	
      if ($result == TRUE) {
 		$response = "{\"status\": \"success\"}";
 }
	else{
	//	$response = "{\"status\": \"error\"}";
      $response = "{\"status\": \"Username Exists\"}";
	}
echo $response;
}
 

?>
