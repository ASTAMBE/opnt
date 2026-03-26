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

  $topicid = $_GET['topicid'];
  $userid = $_GET['userid'];
    

   
    $headers = parseRequestHeaders();
//    print_r($headers);
    $postData  = getPostData();
    
    if (!$topicid || $topicid == ""|| !$userid || $userid == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{
      $message = $postData->postInfo->message;
      $embedded_content = $postData->postInfo->embedded_content;
      $embedded_falg = $postData->postInfo->embedded_flag;
      $postor_country_code = $postData->postInfo->country_code;

                  $json_arry = array();
                 $q = "INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE)VALUES (\"$topicid\", NOW(), \"$userid\",\"$message\",\"$embedded_content\",\"$embedded_falg\", \"$postor_country_code\");";
//		echo $q;
                  $result = mysqli_query($db,$q);
                  if($result == TRUE){
                  $response = "{\"status\": \"success\"}";
                  //echo $r;
                  }
                  else{
                  $response = "{\"status\": \"error\"}";
                  //echo $r;
                  }
    echo $response;
          }
   

  ?>




