<?php
  
include('includeHeader.inc.php');


$fromIndex="";
$toIndex="";
$topicid = $postData['topicid'];
$userid = $postData['userid'];


if(isset($postData['from'])){
  $fromIndex = $postData['from'];
}
if(isset($postData['to'])){
  $toIndex = $postData['to'];
}
if (!$topicid || $topicid == "" || !$userid || $userid == "" ){
     $response = "{\"status\": \"error\"}";
    die($response);
}
if ($fromIndex == ""){
  $fromIndex = 0;
}
if ($toIndex == ""){
  $toIndex = 20;
}

    $q = "call profilePosts(\"$userid\", \"$topicid\",\"$fromIndex\",\"$toIndex\");";
	$json_arry = array();
           $result = mysqli_query($db,$q);
                    if($result == TRUE){
                    while (($row = mysqli_fetch_assoc($result))){
	                      $json['POST_ID'] = $row['POST_ID'];
        	              $json['USERNAME'] =$row['POST_BY_USERNAME'];
                          $json['DP_URL'] =$row['DP_URL'];
                          $json['TOPICID'] =  $row['TOPICID'];
            		      $json['POST_DATETIME'] = $row['POST_DATETIME'];
                   	      $json['POST_CONTENT'] = utf8_encode($row['POST_CONTENT'] );
                          $json['LCOUNT'] = $row['LCOUNT'];
                          $json['HCOUNT'] = $row['HCOUNT'];
                          $json['POST_COMMENT_COUNT'] = $row['POST_COMMENT_COUNT'];
                          array_push($json_arry, $json); 
                     }
                    $r =  json_encode($json_arry);
                     echo $r;
                    }
                   else{
                    $response = "{\"status\": \"error\"}";
                   echo $r;
                    }
  ?>
