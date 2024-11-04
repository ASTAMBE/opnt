<?php
include ('dbconnection.inc');
  
  function getPostData(){
    $value = json_decode(file_get_contents('php://input'));
    return $value;
  }
  function parseRequestHeaders() {
      $headers = array();
      foreach($_SERVER as $key => $value) {
          if (substr($key, 0, 5) <> 'HTTP_') {
              continue;
          }
          $header = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
          $headers[$header] = $value;
      }
  
      return $headers;
  }
  
  
    $headers = parseRequestHeaders();
    print_r($headers);
    $username = $headers['Username'];
    $userid = $headers['Userid'];
    $postData  = getPostData();
    //echo $username;
    //echo $userid;
    //print_r($postData);
    if (!$username || $username == ""|| !$userid || $userid == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{
      foreach ($postData->topics as $topic) {
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
