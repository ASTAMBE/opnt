<?php

include ('dbconnection.inc');





	$username = $_GET['username'];

	if (!$username || $username == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
  	 
	 $q = "SELECT * FROM OPN_USERLIST WHERE USERNAME = \"$username\"" ;
 	 $result = mysqli_query($db,$q);
	if ($result->num_rows > 0) {
		$response = "{\"status\": \"username not available.\"}";
	}
	else{
		$response = "{\"status\": \"success\"}";	 
	}
	echo $response;

      }


?>
