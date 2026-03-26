<?php

include('includeHeader.inc.php');

$username = $postData['username'];
$pwd_answer = $postData['pwd_answer'];

if (!$username || $username == "" ||
	!$pwd_answer || $pwd_answer == ""){
		 $response = "{\"status\": \"Please Enter valid username and password answer.\"}";
	 	die($response);
 }
else{
	 $q = "SELECT EXISTS (SELECT 1 FROM OPN_USERLIST WHERE USERNAME = \"$username\" AND UPPER(PASSWORD_Q_A) = UPPER(\"$pwd_answer\")) userexists" ;
// echo $q;	 	
$result = mysqli_query($db,$q);
			while (($row = mysqli_fetch_array($result))){
    		$json_arry[] =  $row;
		}
	$r =  json_encode($json_arry);
	echo $r ;

}



?>
