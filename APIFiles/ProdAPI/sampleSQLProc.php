<?php
include('includeHeader.inc.php');


$headers = parseRequestHeaders();

if (!authenticateGet($headers)){
  header("HTTP/1.1 401 Unauthorized");
  exit;
}
   
$postData = getPostData();

$topicid = $postData['topicid'];
$userid =$postData['userid'];


       if (!$topicid || $topicid == "" || !$userid || $userid == "" ){
             $response = "{\"status\": \"error\"}";
                 die($response);
      }
      else{
     
      $json_arry = array();
//          $q = "SQLPROC(\"$userid\",\"$topicid\")";
$q = "CALL SQLPROC( \"$userid\",  \"$topicid\");";
     $result = mysqli_query($db,$q);

      while (($row = mysqli_fetch_assoc($result))){
        $json_arry[] =  $row;
      }

      $r =  json_encode($json_arry);
      echo $r ;
}

?>
