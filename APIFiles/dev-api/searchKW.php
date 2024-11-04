<?php
include('includeHeader.inc.php');

$topicid = $postData['topicid'];
$userid =$postData['userid'];
$country_code = $postData['country_code'];

// adding the searchTerm param below:

$searchTerm = $postData['searchTerm'];

if (!$country_code || $country_code == "" || !$searchTerm || $searchTerm == ""){
                 $response = "{\"status\": \"error\"}";
                die($response);
  }


if (!$topicid || $topicid == "" || !$userid || $userid == "" ){
            $response = "{\"status\": \"error\"}";
                die($response);
   	}
	else{

 	$json_arry = array();
 	//$q = "SELECT USERID, TOPICID, CART, KEYID, KEYWORDS,IRANK FROM ( SELECT A.USERID, A.TOPICID, A.CART, A.KEYID, B.KEYWORDS, B.IRANK FROM OPN_USER_CARTS A, OPN_P_KW B WHERE A.KEYID = B.KEYID AND A.USERID = \"$userid\" AND A.TOPICID = \"$topicid\" UNION ALL SELECT \"$userid\" USERID, TOPICID, ' ' CART, Q.KEYID, Q.KEYWORDS, Q.IRANK FROM OPN_P_KW Q WHERE Q.TOPICID = \"$topicid\" AND Q.KEYID NOT IN  (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID =  \"$userid\") )X ORDER BY CART DESC, IRANK ASC;" ;
 	
$q = "CALL searchKW(\"$topicid\", \"$userid\", \"$country_code\", \"$searchTerm\");";

//	echo $q;
$result = mysqli_query($db,$q);

	while (($row = mysqli_fetch_assoc($result))){
        $json_arry[] =  $row;
    	}

 	$r =  json_encode($json_arry);
 	echo $r ;
}	

?>
