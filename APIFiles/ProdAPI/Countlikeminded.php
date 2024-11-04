<?php

  include('includeHeader.inc.php');
  
  
  
  $postData = getPostData();

 $topic_id = $postData['topic_id'];
 $uuid = $postData['uuid'];

 

if (!$topic_id|| $topic_id == "" || !$uuid || $uuid == "" ){
         $response = "{\"status\": \"error\"}";
        die($response);
 }

 $query = "CALL likemindedcount(\"$uuid\",\"$topic_id\");";
 $query1 ="CALL gettopicname(\"$topic_id\")";

 $result = mysqli_query($db,$query);
 $result1 = mysqli_query($db,$query1);
      if($result == TRUE){
                  while (($row = mysqli_fetch_assoc($result))){
                  $json_arry[] =  $row;
                }
                while (($row1 = mysqli_fetch_assoc($result1))){
                  $json_arry[] =  $row1;
                }

          $r =  json_encode($json_arry);
          echo $r;
        }
       else{
            $response = "{\"status\": \"error\"}";
          echo $r;
        }
?>
