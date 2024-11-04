<?php
	include ('dbconnection.inc');

        $username = $_GET['username'];
        $password = $_GET['password'];
        $password_question = $_GET['password_question'];
        $password_answer = $_GET['password_answer']; 
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
  			$response = "{\"status\": \"error\"}";
        	}
		echo $response;
	}
 

?>
