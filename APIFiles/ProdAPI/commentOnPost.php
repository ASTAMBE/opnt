<?php


include('includeHeader.inc.php');


$commentData = $postData["comments"];
$postid = $commentData["postid"];
$userid = $postData["userid"];
$postuserid = $commentData["postuserid"];
$comments = addslashes($commentData['comments']);
$embedded_content = $commentData['embedded_content'];
$topicid = $commentData['topicid'];
$embedded_flag = $commentData['embedded_flag'];


$q = "CALL commentOnPost(\"$postid\", \"$postuserid\", \"$topicid\",\"$comments\", \"$userid\", \"$embedded_content\",\"$embedded_flag\");";
//	echo $q;
$result = mysqli_query($db,$q);

if($result == TRUE){
  $response = "{\"status\": \"success\"}";
}
else{
 $response = "{\"status\": \"error\"}";
}
echo $response;
?>


