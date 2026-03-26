<?php
// include ('dbconnection.inc');
//$db=mysqli_connect('localhost','root','astglobal','testdb');

include('includeHeader.inc.php');

  
  
	$username = $_GET['username'];
	
  
	if (!$username || $username == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
	
  	 $json_arry = array();
	 $q = "SELECT USERID FROM OPN_USERLIST WHERE USERNAME = \"$username\"" ;
//	echo $q;
 	$result = mysqli_query($db,$q);
	while (($row = mysqli_fetch_array($result))){
		$json_arry[] =  $row;
	}
	$r =  json_encode($json_arry);
	echo $r;
	}
 

?>

