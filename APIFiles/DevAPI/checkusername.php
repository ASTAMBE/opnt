<?php

include('includeHeader.inc.php');



	$username = $postData['username'];
	

	if (!$username || $username == "" ){
 	 	 $response =array("status"=>"error");
 		 $json_arry[] =  $response;
 		echo $r =  json_encode($json_arry);
	 }

	else{

		$q = "CALL checkusername(\"$username\") ;";
		$result = mysqli_query($db,$q);
		if($result == TRUE){
			while (($row = mysqli_fetch_assoc($result))){
					$count =  $row['count'];
			 }
			 if($count== 1){
                  $response =array("status"=>"Username Exists");
 		          $json_arry[] =  $response;
 		          echo $r =  json_encode($json_arry);
			 }else{
                   $response =array("status"=>"Username Available");
 		          $json_arry[] =  $response;
 		          echo $r =  json_encode($json_arry);
			 }
		}
		else{
		 $response =array("status"=>"something wrong happend");
 		 $json_arry[] =  $response;
 		echo $r =  json_encode($json_arry);
		}
}
?>
