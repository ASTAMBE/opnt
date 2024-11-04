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
//	 echo "test1";
          $header = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
          $headers[$header] = $value;
      }
  //    echo $headers; 
     return $headers;
 }
	$topicid = $_GET['topicid'];
 	$userid = $_GET['userid'];
 
   
    $headers = parseRequestHeaders();
//    print_r($headers);
    //$username = $headers['topic'];
    //$userid = $headers['Userid'];
    $postData  = getPostData();
    
//    echo $topicid;
  //  echo $userid;
  //  print_r($postData);
    
    if (!$topicid || $topicid == ""|| !$userid || $userid == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{

	$q = "DELETE FROM OPN_USER_CARTS WHERE USERID = \"$userid\" AND TOPICID = \"$topicid\";";
      	//echo $q;          
      	$result = mysqli_query($db,$q);
     
      foreach ($postData->topiccarts as $topic) {
	if ($topic->CART == "L"|| $topic->CART == "H"){  
	 $q = "INSERT INTO OPN_USER_CARTS(TOPICID, USERID, KEYID, CART, CREATION_DTM) VALUES (\"$topicid\", \"$userid\", \"{$topic->KEYID}\",\"{$topic->CART}\", NOW())";
      	//echo $q;
	 //$q = "CALL NEWCART_TOP( \"$userid\",  \"$topic_id\");";          
     	 $result = mysqli_query($db,$q);
	}
      }
	$q = "CALL NEWCART_TOP( \"$userid\",  \"$topicid\");"; 
        $result = mysqli_query($db,$q);
	$response = "{\"status\": \"success\"}";
       echo $response;
    }
  
  
 ?>
