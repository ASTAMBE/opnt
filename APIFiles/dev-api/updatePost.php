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

  $userid = $_GET['userid'];
    
    $headers = parseRequestHeaders();

    $postData  = getPostData();
    
    if (!$userid || $userid == ""){
      	$response = "{\"status\": \"invalid parameters error\"}";
      	die($response);
    }
    else{
      $message = $postData->postInfo->message;
      $embedded_content = $postData->postInfo->embedded_content;
      $post_id = $postData->postInfo->postid;
      $embedded_flag = $postData->postInfo->embedded_flag;
      
          if (!$post_id || $post_id == ""){
      			$response = "{\"status\": \"invalid Post Id  error\"}";
      			die($response);
    		}

                  $json_arry = array();
                  $q = "UPDATE OPN_POSTS_RAW SET POST_DATETIME = NOW(), POST_CONTENT = \"$message\" , EMBEDDED_CONTENT = \"$embedded_content\", EMBEDDED_FLAG = \"$embedded_flag\" WHERE POST_ID = \"$post_id\";";
		  echo $q;
                  $result = mysqli_query($db,$q);
                  if($result == TRUE){
                  		$response = "{\"status\": \"success\"}";
                  }
                  else{
                  		$response = "{\"status\": \"error\"}";
                  }
    echo $response;
          }
   

  ?>
