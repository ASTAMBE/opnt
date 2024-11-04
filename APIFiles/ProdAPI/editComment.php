<?php

include('includeHeader.inc.php');



$commentData = $postData["comments"];
$userid = $postData["userid"];

$comments = addslashes($commentData['comments']);
$embedded_content = $commentData['embedded_content'];
$commentid = $commentData['commentid'];
$embedded_flag = $commentData['embedded_flag'];



//$q = "UPDATE OPN_POST_COMMENTS_RAW SET COMMENT_CONTENT = \"$comments\", COMMENT_DTM = NOW(), EMBEDDED_CONTENT = \"$embedded_content\", EMBEDDED_FLAG =\"$embedded_flag\", CLEAN_COMMENT_FLAG = 'N' WHERE COMMENT_ID = \"$commentid\";";

$q = "CALL editComment( \"$userid\", \"$commentid\", \"$comments\", \"$embedded_content\", \"$embedded_flag\");";

//  echo $q;
$result = mysqli_query($db,$q);

if($result == TRUE){
	$response = "{\"status\": \"success\"}";
}
else{
	$response = "{\"status\": \"error\"}";
}
echo $response;


?>
