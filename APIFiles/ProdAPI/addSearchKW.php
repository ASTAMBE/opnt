
<?php

include('includeHeader.inc.php');



$topicid = $postData['topicid'];
$userid =$postData['userid'];
$country_code = $postData['country_code'];
$userKW = $postData['userKW'];
$usercart = $postData['usercart'];


if (!$topicid || $topicid == "" || !$userid || $userid == ""|| !$country_code || $country_code == ""|| !$searchTerm || $searchTerm == "" ){
  $response = "{\"status\": \"error\"}";
  die($response);
}
else{

  $q = "call addSearchKW(\"$topicid\", \"$userid\", \"$country_code\", \"$userKW\" , \"$usercart\"));";

  $result = mysqli_query($db,$q);

  if($result == TRUE){

    $response = "{\"status\": \"success\"}";

  }else{
      $response = "{\"status\": \"New Topic Rejected\"}";
  }
  echo $response;

}


?>
