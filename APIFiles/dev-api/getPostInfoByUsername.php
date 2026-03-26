

<?php
  
     include ('dbconnection.inc');
   
             $userid = $_GET['userid'];
             $topicid = $_GET['topicid'];
   
             if (!$userid || $userid == "" || !$topicid || $topicid == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{



	$q = "SELECT POST_ID FROM OPN_POSTS WHERE POST_BY_USERID = \"$userid\" AND TOPICID = \"$topicid\"  ORDER BY POST_DATETIME DESC;";

           $result = mysqli_query($db,$q);
                    if($result == TRUE){
                    while (($row = mysqli_fetch_assoc($result))){
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
  
  
  ?>
