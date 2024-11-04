<?php
  
     include ('dbconnection.inc');
   
             $userid = $_GET['userid'];
             $topicid = $_GET['topicid'];
   
             if (!$userid || $userid == "" || !$topicid || $topicid == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{

    $q = "SELECT P.POST_ID, OU.USERNAME POST_BY_USERNAME, P.TOPICID, P.POST_DATETIME, P.POST_CONTENT, IFNULL(POST_LHC.LCOUNT,0) LCOUNT
, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, IFNULL(OPC.POST_COMMENT_COUNT, 0) POST_COMMENT_COUNT
FROM OPN_POSTS P
INNER JOIN OPN_USERLIST OU ON P.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON P.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' GROUP BY CAUSE_POST_ID) OPC 
ON P.POST_ID = OPC.CAUSE_POST_ID
WHERE TOPICID = \"$topicid\" AND POST_BY_USERID =  \"$userid\"
ORDER BY P.POST_DATETIME DESC;";
	$json_arry = array();
           $result = mysqli_query($db,$q);
                    if($result == TRUE){
                    while (($row = mysqli_fetch_assoc($result))){
                           // $json_arry[] =  $row;
	                      $json['POST_ID'] = $row['POST_ID'];
        	              $json['USERNAME'] =$row['POST_BY_USERNAME'];
                              $json['TOPICID'] =  $row['TOPICID'];
            		      $json['POST_DATETIME'] = $row['POST_DATETIME'];
                   	      $json['POST_CONTENT'] = utf8_encode($row['POST_CONTENT'] );
        		      $json['LCOUNT'] = $row['LCOUNT'];
        		      $json['HCOUNT'] = $row['HCOUNT'];
        		      $json['POST_COMMENT_COUNT'] = $row['POST_COMMENT_COUNT'];
        //$json['POST_CONTENT'] = $row['POST_CONTENT'];
     
             array_push($json_arry, $json); 
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
