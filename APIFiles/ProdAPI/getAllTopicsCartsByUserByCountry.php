<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$topicid = $postData['topicid'];
$userid =$postData['userid'];
$country_code = $postData['country_code'];
$token = $headers['Token'];

if(!$country_code || $country_code == "" || $token == ""){
                 $response = "{\"status\": \"error\"}";
                die($response);
  }


if (!$topicid || $topicid == "" || !$userid || $userid == ""){
            $response = "{\"status\": \"error\"}";
                die($response);
   	}
	else{
		if($verify=verify_jwt_by_userid($token,$userid)){
 
		}else{
					$response =array("status"=>"Authentication Failed");
					http_response_code(401);
					print json_encode($response);
					die();
		  }

 	$json_arry = array();
 	//$q = "SELECT USERID, TOPICID, CART, KEYID, KEYWORDS,IRANK FROM ( SELECT A.USERID, A.TOPICID, A.CART, A.KEYID, B.KEYWORDS, B.IRANK FROM OPN_USER_CARTS A, OPN_P_KW B WHERE A.KEYID = B.KEYID AND A.USERID = \"$userid\" AND A.TOPICID = \"$topicid\" UNION ALL SELECT \"$userid\" USERID, TOPICID, ' ' CART, Q.KEYID, Q.KEYWORDS, Q.IRANK FROM OPN_P_KW Q WHERE Q.TOPICID = \"$topicid\" AND Q.KEYID NOT IN  (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID =  \"$userid\") )X ORDER BY CART DESC, IRANK ASC;" ;
 	
$q = "CALL getAllTopicsCartsByUserByCountry(\"$topicid\", \"$userid\", \"$country_code\");";

//	echo $q;
$result = mysqli_query($db,$q);

	while (($row = mysqli_fetch_assoc($result))){
        $json_arry[] =  $row;
    	}

 	$r =  json_encode($json_arry);
 	echo $r ;
}	

?>
