<?php

include('includeHeader.inc.php');




$userid = $postData['userid'];
$topicid = $postData['topicid'];
$userKW = $postData['userKW'];


if (!$userid || $userid == "" ||  !$userKW || $userKW == "" ) {
    $response = "{\"status\": \"error\"}";
    die($response);
}
else {


  $json_arry = array();
  $q = "call checkNewKwOK(\"$userid\", \"$topicid\", \"$userKW\");";
  $result = mysqli_query($db,$q);
      if($result == TRUE) {
          while (($row = mysqli_fetch_assoc($result))) {
                if(empty($row['CHKSTATUS'])){
                    $row['CHKSTATUS'] = "0";
                }
                 $json_arry[] =  $row;
           	}
         	$r =  json_encode($json_arry);
         	echo $r;
          //$response = "{\"status\": \"$result\"}";
          //echo $response;
       }
       else{
          	$response = "{\"status\": \"opinito policy violated.\"}";
         	echo $response;
        }
}
?>
