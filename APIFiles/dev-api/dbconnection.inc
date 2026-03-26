<?php

 header("Access-Control-Allow-Origin: *");
  //header("Access-Control-Allow-Origin", 'http://localhost:8080');
  header('Access-Control-Allow-Methods', 'POST,GET,OPTIONS,PUT,DELETE');
  header('Access-Control-Allow-Headers', 'Content-Type,Accept');

  $dbhost = 'prodopnt.cidtah9kj29d.us-west-1.rds.amazonaws.com';
  $dbport = '3306';
  $dbname = 'opntprod';
  $charset = 'utf8' ;
  
  $dsn = "mysql:host={$dbhost};port={$dbport};dbname={$dbname};charset={$charset}";
  $username = 'root';
  $password = 'nemo@6312';
  
  //$pdo = new PDO($dsn, $username, $password);
  
  $db = mysqli_connect($dbhost, $username,$password, $dbname, $dbport);

// $db=mysqli_connect('localhost','root','astglobal','testdb');

 if (mysqli_connect_errno()){
    $error =  "Failed to connect to MySQL: " . mysqli_connect_error();
  	$response = "{\"status\": \"$error\"}";
    echo $response;
 }

?>
