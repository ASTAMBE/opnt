<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

$topicid = $postData['topicid'];
$userid =$postData['userid'];
$country_code = $postData['country_code'];
$token = $headers['Token'];

// adding the searchTerm param below:

$searchTerm = $postData['searchTerm'];

if (!$country_code || $country_code == "" || !$searchTerm || $searchTerm == ""){
                 $response = "{\"status\": \"error\"}";
                die($response);
  }


if (!$topicid || $topicid == "" || !$userid || $userid == "" || $token == "" ){
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
 	
$q = "CALL searchkeyword(\"$topicid\", \"$userid\", \"$country_code\", \"$searchTerm\");";

//	echo $q;
$result = mysqli_query($db,$q);

	while (($row = mysqli_fetch_assoc($result))){
        $json_arry[] =  $row;
    	}

 	$r =  json_encode($json_arry);
 	echo $r ;
}	

?>
