<?php
include('includeHeader.inc.php');

	$topicid = $postData['topicid'];
 	$userid = $postData['userid'];
	 $country_code = $postData['country_code'];
	 

    $headers = parseRequestHeaders();

    if (!$topicid || $topicid == ""|| !$userid || $userid == "" ){
      $response = "{\"status\": \"invalid parameters error\"}";
      die($response);
    }
    else{
		foreach (json_decode($postData['topiccarts']) as $topic) {
			//echo $topic->CART;
			if ($topic->CART == "L"|| $topic->CART == "H"){  

			$q = "call addSearchKwToCart( \"$topicid\", \"$country_code\", \"$userid\", \"{$topic->CART}\" , \"{$topic->KEYID}\"); ";    

				$result = mysqli_query($db,$q);
			}
		}

		$response = "{\"status\": \"success\"}";
		echo $response;
    }  
 ?>
