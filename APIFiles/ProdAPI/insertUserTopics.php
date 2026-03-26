<?php
include('includeHeader.inc.php');


   $db=mysqli_connect('localhost','root','astglobal','testdb');

   if (mysqli_connect_errno()){
    $error =  "Failed to connect to MySQL: " . mysqli_connect_error();
    $response = "{\"status\": \"$error\"}";
          echo $response;
  }
  else{

          $topicid = $_GET['topicid'];
          $userid = $_GET['userid'];
          $postid = $_GET['postid'];
          $postuserid = $_GET['postuserid'];
          


          if (!$topicid || $topicid == "" || !$username || $username == "" ){
                   $response = "{\"status\": \"error\"}";
                  die($response);
           }
          else{
                  $json_arry = array();
                 $q = "INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM, CAUSE_POST_ID, TOPICID) VALUES (\"$userid\",\"$postuserid\", 'H', NOW(), \"$postid\", \"$topicid\");";

                  $result = mysqli_query($db,$q);
                  if($result == TRUE){
                  while (($row = mysqli_fetch_array($result))){
                          $json_arry[] =  $row;
                   }
                  $r =  json_encode($json_arry);
                  echo $r;
                  }
                  else{
                  $response = "{\"status\": \"error\"}";
                  echo $r;
                  }
          }
   }

  ?>
