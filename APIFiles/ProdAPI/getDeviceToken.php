<?php
// include ('dbconnection.inc');
//$db=mysqli_connect('localhost','root','astglobal','testdb');

include('includeHeader.inc.php');
  
  
	$username = $_GET['username'];
	//$token = $headers['Token'];
  
	if (!$username || $username == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
  	 $json_arry = array();
	 //$q = "SELECT USERID FROM OPN_USERLIST WHERE USERNAME = \"$username\"" ;
	 $q = "SELECT IDENTIFIER_TOKEN FROM OPN_USERLIST WHERE USERNAME = \"$username\"" ;
	//  SELECT IDENTIFIER_TOKEN FROM OPN_USERLIST WHERE USERNAME LIKE  ('ASTCMC%') ;
//	echo $q;
 	$result = mysqli_query($db,$q);
	while (($row = mysqli_fetch_array($result))){
		$json_arry[] =  $row;
	}
	$r =  json_encode($json_arry);
	echo $r;
	}
 

?>

