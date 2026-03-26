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
      //print_r($headers);
      $tempPostData  = getPostData();
      //print_r($postData);
  
      //print_r($postData->comments);
      $postData = $tempPostData->comments;
      $q = "UPDATE OPN_POST_COMMENTS_RAW SET COMMENT_CONTENT = '$postData->comments', COMMENT_DTM = NOW(), EMBEDDED_CONTENT = '$postData->embedded_content', EMBEDDED_FLAG = '$postData->embedded_flag', CLEAN_COMMENT_FLAG = 'N' WHERE COMMENT_ID = '$postData->commentid';";
     //  echo $q;
      $result = mysqli_query($db,$q);
      
      if($result == TRUE){
            $response = "{\"status\": \"success\"}";
        }
       else{
           $response = "{\"status\": \"error\"}";
        }
        echo $response;
      
 
  ?>
