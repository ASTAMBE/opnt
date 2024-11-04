<?php
include('includeHeader.inc.php');
header('Content-type: application/json');

$limit= $postData['begin'];
 $offset = $postData['row_per_page'];



  	$json_arry = array();
	$json= array();
	 $q = "SELECT * FROM WSR_UNTAGGED WHERE COUNTRY_CODE = 'IND' ORDER BY ROW_ID DESC LIMIT $limit, $offset " ;
 	$result = mysqli_query($db,$q);
		// print_r($result);
		// exit();
	if($result == TRUE){
    	while (($row = mysqli_fetch_assoc($result))){

		$data=array('NEWS_DATE'=>$row['NEWS_DATE'], 'SCRAPE_TOPIC'=>$row['SCRAPE_TOPIC'], 'NEWS_HEADLINE'=>$row['NEWS_HEADLINE'], 'NEWS_URL'=>$row['NEWS_URL'] );

      		$json[] =  $data;
			  
    	} 

		if(empty(array_filter($json))){
			$r =  $response = "{\"status\": \"Error\", \"Message\": \"Data Not Found\"}";
			echo $r;
		}
		else{
		  	$json_arry['status'] = 'success';
		  	$json_arry['data'] = $json;
		  	$r =  json_encode($json_arry);
		  	echo $r;
		}
		
    }
    else{
		$response = "{\"status\": \"error\"}";
		echo $r;
   	}
	
	
	 

?>

