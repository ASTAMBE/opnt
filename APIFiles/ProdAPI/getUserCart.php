<?php

include ('dbconnection.inc');
include('util.php');

$headers = parseRequestHeaders();

if (!authenticateGet($headers)){
  header("HTTP/1.1 401 Unauthorized");
  exit;
}
   
$postData = getPostData();

$topicid = '1';//$_GET['topicid'];
$username = '1000566';//$_GET['username'];

if (!$topicid || $topicid == "" || !$username || $username == ""){
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
        $json_arry = array();
       $q = "SELECT USERID, TOPICID, CART, KEYWORDS, IRANK FROM ( SELECT A.USERID, A.TOPICID, A.CART, B.KEYWORDS, B.IRANK FROM OPN_USER_CARTS A, OPN_P_KW B WHERE A.KEYID = B.KEYID AND A.USERID = \"$username\" AND A.TOPICID = \"$topicid\" UNION ALL SELECT \"$username\" USERID, TOPICID, ' ' CART, Q.KEYWORDS, Q.IRANK FROM OPN_P_KW Q WHERE Q.TOPICID = \"$topicid\" AND Q.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = \"$username\") )X ORDER BY CART DESC, IRANK ASC;";

        $result = mysqli_query($db,$q);
        if($result == TRUE){
        while (($row = mysqli_fetch_array($result))){
                $json_arry[] =  $row;
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
