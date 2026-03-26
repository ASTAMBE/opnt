<?php
	include ('dbconnection.inc');

//$db=mysqli_connect('localhost','root','astglobal','testdb');

//if (mysqli_connect_errno()){
  //$error =  "Failed to connect to MySQL: " . mysqli_connect_error();
  //$response = "{\"status\": \"$error\"}";
//	echo $response;
//}
//else{

	$username = $_GET['username'];

	if (!$username || $username == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
  	 	
	 	$q = "SELECT * from OPN_USERTOPIC where username =\"$username\"";
		
 		$result = mysqli_query($db,$q);
 		 
    		
		if ($result->num_rows > 0) {
			$response = "{\"status\": \"success\"}";
		}
		else{
 			$response = "{\"status\": \"No topics are avialable.\"}";
		}
		
		echo $response ;
	}

 //}

?>
