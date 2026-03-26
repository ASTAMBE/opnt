<?php

include('includeHeader.inc.php');

$username = $postData['username'];
if (!$username || $username == ""){
		 $response = "{\"status\": \"error\"}";
	 	die($response);
 }
else{
	 
 //$q = "SELECT 1 FROM OPN_USERLIST WHERE UPPER(USERNAME) = UPPER(\"$username\")" ;

 $q = "call doesUsernameExist(\"$username\");" ;

	 $result = mysqli_query($db,$q);
if ($result->num_rows < 1) {
	$response = "{\"status\": \"username not available.\"}";
}
else{
	$response = "{\"status\": \"success\"}";	 
}
echo $response;

  }


?>
