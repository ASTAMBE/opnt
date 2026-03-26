<?php

  include ('dbconnection.inc');

          $topicid = $_GET['topicid'];
          $userid = $_GET['userid'];
          $postid = $_GET['postid'];
          $postuserid = $_GET['postuserid'];

          if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$postid || $postid == "" || !$postuserid || $postuserid == ""){
                   $response = "{\"status\": \"error\"}";
                  die($response);
           }
          else{

		$delQuery = "DELETE FROM OPN_USER_POST_ACTION WHERE ACTION_BY_USERID = \"$userid\" AND CAUSE_POST_ID = \"$postid\";";
		$result = mysqli_query($db,$delQuery);
		if($result == FALSE){
                          
                     $response = "{\"status\": \"error\"}";
                    die($response);
                 }
		
                 
                 $q = "INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM, CAUSE_POST_ID, TOPICID) VALUES (\"$userid\",\"$postuserid\", 'L', NOW(), \"$postid\", \"$topicid\");";
//echo $q;
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
