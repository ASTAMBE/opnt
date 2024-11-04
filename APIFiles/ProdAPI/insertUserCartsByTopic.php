<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');
include('jwt_verify.php');

	$topicid = $postData['topicid'];
 	$userid = $postData['userid'];
	 $token = $headers['Token'];
	 
    if (!$topicid || $topicid == ""|| !$userid || $userid == "" || $token == ""){
      $response = "{\"status\": \"invalid parameters error\"}";
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

	//	$q = "DELETE FROM OPN_USER_CARTS WHERE USERID = \"$userid\" AND TOPICID = \"$topicid\";";  

		$q = "call insertCartDelQ(\"$userid\", \"$topicid\");";  


		$result = mysqli_query($db,$q);
		foreach (json_decode($postData['topiccarts']) as $topic) {
			echo $topic->CART;
			if ($topic->CART == "L"|| $topic->CART == "H"){  

			//	$q = "INSERT INTO OPN_USER_CARTS(TOPICID, USERID, KEYID, CART, CREATION_DTM) VALUES (\"$topicid\", \"$userid\", \"{$topic->KEYID}\",\"{$topic->CART}\", NOW())";    

				$q = "call insertCartInsertQ(\"$userid\", \"$topicid\", \"{$topic->KEYID}\", \"{$topic->CART}\" ); ";    

				$result = mysqli_query($db,$q);
			}
		}

// 070517 AST: ADDING THE PORTION BELOW TO MAKE THE CART.LUDTM AS THE BASIS FOR CLUSTERING
		
				$q = "CALL ludtmUpdate( \"$userid\",  \"$topicid\");"; 
		$result = mysqli_query($db,$q);
	//	$response = "{\"status\": \"success\"}";
	//	echo $response;

		// END OF ADDITION


	//	$q = "CALL NEWCART_TOP( \"$userid\",  \"$topicid\");"; 
	//	$result = mysqli_query($db,$q);

// 05/05/2019 AST: Removed lines 42 and 43 above - because the clustering is not required anymore

		$response = "{\"status\": \"success\"}";
		echo $response;
    }
  
  
 ?>
