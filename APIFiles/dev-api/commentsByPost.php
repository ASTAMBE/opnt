<?php

	include ('dbconnection.inc');
   
             $postid = $_GET['postid'];
   
             if (!$postid || $postid == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{



	$q = "CALL commentsByPost(\"$postid\");";
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
			$json['COMMENT_SEQ'] = $row['COMMENT_SEQ'];
			$json['COMMENT_CONTENT'] = utf8_encode($row['COMMENT_CONTENT'] );
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
