<?php

include('includeHeader.inc.php');


$topicid = $postData['topicid'];
$userid = $postData['userid'];
$message = addslashes($postData['message']);


if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$message || $message == "" ){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
       
        $json_arry = array();
       $q = "INSERT INTO OPN_POSTS(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT)VALUES (\"$topicid\", NOW(), \"$userid\",\"$message\");";

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



