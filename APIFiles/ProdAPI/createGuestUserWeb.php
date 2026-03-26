<?php

include('includeHeader.inc.php');

	$country = $postData['country'];

	if (!$country || $country == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
		$q = "CALL createGuestUserWeb(\"$country\") ;";
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
			echo $response;
		}
}
?>
