<?php

include('includeHeader.inc.php');


 $postid = $postData['postid'];
 // 04272018 AST: Adding userid (user_uuid of the logged in user) - for the purpose of comments KO handling
 // the second param (\"$userid\") in the actual call is added as part of this change
 // this is not working - why?
 $userid = $postData["userid"];
 

 if (!$postid || $postid == "" ){
          $response = "{\"status\": \"error\"}";
        die($response);
 }
else{



$q = "CALL commentsByPost(\"$postid\", \"$userid\");";
$json_arry = array();
         $result = mysqli_query($db,$q);
                  if($result == TRUE){
                  while (($row = mysqli_fetch_assoc($result))){

//	               $json_arry[] =  $row;
		$json['TOPICID'] =  $row['TOPICID'];
		$json['CAUSE_POST_ID'] = $row['CAUSE_POST_ID'];
		$json['COMMENT_BY_USERID'] = $row['COMMENT_BY_USERID'];
		$json['COMMENT_ID'] = $row['COMMENT_ID'];
		$json['USERNAME'] =$row['USERNAME'];
    $json['DP_URL'] =$row['DP_URL'];
		$json['COMMENT_SEQ'] = $row['COMMENT_SEQ'];
		$json['COMMENT_CONTENT'] = $row['COMMENT_CONTENT'] ;
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
