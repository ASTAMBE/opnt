<?php
  
  
//    $db=mysqli_connect('localhost','root','astglobal','testdb');
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
      //print_r($headers);
      $tempPostData  = getPostData();
      //print_r($postData);
  
      //print_r($postData->comments);
          $postData = $tempPostData->comments;
 	  $q = "INSERT INTO OPN_POST_COMMENTS_RAW (CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG) VALUES ('$postData->postid', '$postData->postuserid', '$postData->topicid', 
		(SELECT IFNULL(MAX_SEQ+1,1) FROM (SELECT CAUSE_POST_ID, MAX(COMMENT_SEQ) MAX_SEQ FROM OPN_POST_COMMENTS_RAW WHERE CAUSE_POST_ID = '$postData->postid') M),'$postData->comments','$postData->userid',NOW(),'$postData->embedded_content','$postData->embedded_flag');";
//	echo $q;
      $result = mysqli_query($db,$q);
      
      if($result == TRUE){
            $response = "{\"status\": \"success\"}";
        }
       else{
           $response = "{\"status\": \"error\"}";
        }
        echo $response;
      
 
  ?>


