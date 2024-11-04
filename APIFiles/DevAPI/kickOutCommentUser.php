
<?php

include('includeHeader.inc.php');


$topicid = $postData['topicid'];
$userid = $postData['userid'];
$postid = $postData['postid'];
$commentid = $postData['commentid'];


//$postuserid = $postData['postuserid'];
//$comment = $postData['message'];

if (!$topicid || $topicid == "" || !$userid || $userid == "" || !$postid || $postid == "" || !$commentid || $commentid == "" ){
 $response = "{\"status\": \"error1\"}";
die($response);
}
else{
     
//$delQuery = "DELETE FROM OPN_USER_USER_ACTION WHERE BY_USERID = \"$userid\"  AND ON_USERID = \"$postuserid\";";

// $delQuery = "call KOUserDelQbyUID(\"$userid\", \"$postuserid\", \"$postid\", \"$topicid\");";

$delQuery = "call CKOUserDelQbyUID(\"$userid\",  \"$postid\", \"$topicid\" , \"$commentid\");";


$result = mysqli_query($db,$delQuery);
if($result == FALSE){
     $response = "{\"status\": \"error2\"}";
     die($response);
}

//$q = "INSERT INTO OPN_USER_USER_ACTION (TOPICID, BY_USERID, ON_USERID, ACTION_TYPE, CAUSE_POST_ID, ACTION_DTM, ACTION_COMMENT) VALUES (\"$topicid\", \"$userid\",\"$postuserid\", 'KO', \"$postid\", NOW(), \"$comment\");";

// $q = "call KOUserInsertQbyUID(\"$userid\", \"$postuserid\", \"$postid\", \"$topicid\");";

$q = "call CKOUserInsertQbyUID(\"$userid\",  \"$postid\", \"$topicid\" , \"$commentid\");";


$result = mysqli_query($db,$q);
if($result == TRUE){

   $response = "{\"status\": \"success\"}";

}
else{
$response = "{\"status\": \"error3\"}";

}
echo $response;
}


?>
