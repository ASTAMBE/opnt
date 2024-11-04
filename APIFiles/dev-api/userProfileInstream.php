<?php
include ('dbconnection.inc');
   
             $topicid = $_GET['topicid'];
             $userid = $_GET['userid'];
   
             if (!$topicid || $topicid == "" || !$userid || $userid == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{
                    $json_arry = array();
        $q = "SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_CONTENT, IFNULL(POST_LHC.LCOUNT,0) LCOUNT
, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, IFNULL(OPC.POST_COMMENT_COUNT, 0) POST_COMMENT_COUNT
FROM OPN_POSTS P
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON P.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS GROUP BY CAUSE_POST_ID) OPC 
ON P.POST_ID = OPC.CAUSE_POST_ID
WHERE TOPICID = \"$topicid\" AND POST_BY_USERID = \"$userid\"
ORDER BY P.POST_DATETIME DESC;";
  
 //              echo $q;
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
