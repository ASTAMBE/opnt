
<?php

include('includeHeader.inc.php');


//echo "open db";
   $topicid = $postData['topicid'];
    $userid = $postData['userid'];
    $postid = $postData['postid'];
    $postuserid = $postData['postuserid'];
    

    if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$postid || $postid == "" || !$postuserid || $postuserid == "" ){
             $response = "{\"status\": \"error\"}";
            die($response);
     }
    else{

	
//$delQuery = "DELETE FROM OPN_USER_POST_ACTION WHERE ACTION_BY_USERID = \"$userid\" AND CAUSE_POST_ID = \"$postid\";";

$delQuery = "call hatePostDelQbyUID(\"$userid\",\"$postuserid\", \"$postid\", \"$topicid\");";

           $result = mysqli_query($db,$delQuery);
           if($result == FALSE){

                 $response = "{\"status\": \"error\"}";
               // die($response);
             }
//	echo $delQuery;
//	echo $response;
            $json_arry = array();

         //  $q = "INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM, CAUSE_POST_ID, TOPICID) VALUES (\"$userid\",\"$postuserid\", 'H', NOW(), \"$postid\", \"$topicid\");";

           $q = "call hatePostInsertQbyUID(\"$userid\",\"$postuserid\", \"$postid\", \"$topicid\");";


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
