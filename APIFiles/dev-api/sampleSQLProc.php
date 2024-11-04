<?php
   include ('dbconnection.inc');
  
   $topicid = $_GET['topicid'];
   $userid =$_GET['userid'];
   
           if (!$topicid || $topicid == "" || !$userid || $userid == ""){
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
