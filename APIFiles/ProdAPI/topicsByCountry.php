<?php

 include ('dbconnection.inc');
include('util.php');

$headers = parseRequestHeaders();

if (!authenticateGet($headers)){
  header("HTTP/1.1 401 Unauthorized");
  exit;
}
   
$postData = getPostData();

$country_code = $postData['country_code'];
if (!$country_code || $country_code == ""){
                   $response = "{\"status\": \"error\"}";
                  die($response);
   }

 $json_arry = array();
 $q = "select * from OPN_TOPICS" ;
 $result = mysqli_query($db,$q);
 while (($row = mysqli_fetch_array($result)))
    {
        $json_arry[] =  $row;
    }



 $r =  json_encode($json_arry);

 echo $r ;


?>
