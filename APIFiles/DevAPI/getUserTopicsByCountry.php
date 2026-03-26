<?php

include('includeHeader.inc.php');


$username = $postData['userid'];
$country_code = $postData['country_code'];


if (!$country_code || $country_code == ""){
           $response = "{\"status\": \"error\"}";
          die($response);
  }

if (!$username || $username == "" ){
	 $response = "{\"status\": \"error\"}";
 	die($response);
}
else{


	
 	$json_arry = array();
	$q = "SELECT DISTINCT A.TOPICID, B.TOPIC, B.CODE
FROM OPN_USER_CARTS A, OPN_TOPICS B
WHERE A.USERID = \"$username\" AND A.TOPICID = B.TOPICID ORDER BY A.TOPICID;";//"SELECT DISTINCT  TOPICID, TOPIC,CODE FROM OPN_USER_CARTS WHERE USERID = \"$username\"" ;
// 		echo $q;
$result = mysqli_query($db,$q);
	if($result == TRUE){
while (($row = mysqli_fetch_assoc($result))){
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
//}

?>
