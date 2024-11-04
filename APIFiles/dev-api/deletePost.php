
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
  $postid = $_GET['postid'];

    
    if (!$userid || $userid == "" || !$postid || $postid == ""){
      	$response = "{\"status\": \"invalid parameters error\"}";
      	die($response);
    }
    else{
    	$json_arry = array();
        $q = "DELETE FROM OPN_POSTS WHERE POST_ID = \"$postid\";";
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
