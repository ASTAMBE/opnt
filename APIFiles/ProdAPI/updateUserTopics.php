<?php
include ('dbconnection.inc');
  include('util.php');

$headers = parseRequestHeaders();

if (!authenticateGet($headers)){
  header("HTTP/1.1 401 Unauthorized");
  exit;
}
   
$postData = getPostData();

  
    $headers = parseRequestHeaders();

    $username = $headers['Username'];
    $userid = $headers['Userid'];
    //echo $username;
    //echo $userid;
    //print_r($postData);
    if (!$username || $username == ""|| !$userid || $userid == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{
      foreach ($postData['topics'] as $topic) {
      $q = "UPDATE OPN_USERTOPIC SET INTEREST = \"{$topic->INTEREST}\"  WHERE  USERID = \"$userid\" AND TOPICID = \"{$topic->TOPICID}\"";
      //echo $q;          
      $result = mysqli_query($db,$q);
	if($result ===FALSE){
	echo "{\"status\": \"Unable to update records.\"}";
	}
      }
      $response = "{\"status\": \"success\"}";
      echo $response;
   }
  

?>
