<?php

include('includeHeader.inc.php');

 $uc1 = $postData['uc1'];
 $uc2 = $postData['uc2'];
 $topicid = $postData['topicid'];

 if (!$uc1 || $uc1 == "" || !$uc2 || $uc2 == ""){
          $response = "{\"status\": \"error\"}";
        die($response);
 }
else{


/*$q = "SELECT T1.TOPIC, UC1.CART, K2.KEYWORDS
FROM OPN_USER_CARTS UC1, OPN_TOPICS T1, OPN_P_KW K1, OPN_USERLIST UL1,
OPN_USER_CARTS UC2, OPN_TOPICS T2, OPN_P_KW K2, OPN_USERLIST UL2 
WHERE UC1.USERID = UL1.USERID
AND UC1.TOPICID = T1.TOPICID
AND UC1.KEYID = K1.KEYID
AND UC1.USERID = \"$uc1\"
AND UC1.TOPICID = \"$topicid\"
AND UC2.USERID = UL2.USERID
AND UC2.TOPICID = T2.TOPICID
AND UC2.KEYID = K2.KEYID
AND UC2.USERID = \"$uc2\"
AND UC1.CART = UC2.CART
AND UC1.KEYID = UC2.KEYID
ORDER BY UC1.TOPICID, UC1.CART DESC
;"; */

$q = "call getNetworkDetails(\"$uc1\", \"$uc2\", \"$topicid\");";

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


?>
