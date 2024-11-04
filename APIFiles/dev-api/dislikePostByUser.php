

  <?php

   include ('dbconnection.inc');

          $topicid = $_GET['topicid'];
          $userid = $_GET['userid'];
          $postid = $_GET['postid'];
          $postuserid = $_GET['postuserid'];
          $comment = ' ';

         if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$postid || $postid == "" || !$postuserid || $postuserid == ""){
                   $response = "{\"status\": \"error\"}";
                  echo $response;
           }
          else{
               
		$delQuery = "DELETE FROM OPN_USER_USER_ACTION WHERE BY_USERID = \"$userid\"  AND ON_USERID = \"$postuserid\";";
                 $result = mysqli_query($db,$delQuery);
                  if($result == FALSE){
                      $response = "{\"status\": \"error\"}";
                      die($response);
                  }

                 $q = "INSERT INTO OPN_USER_USER_ACTION (TOPICID, BY_USERID, ON_USERID, ACTION_TYPE, CAUSE_POST_ID, ACTION_DTM, ACTION_COMMENT) VALUES (\"$topicid\", \"$userid\",\"$postuserid\", 'H', \"$postid\", NOW(), \"$comment\");";
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



