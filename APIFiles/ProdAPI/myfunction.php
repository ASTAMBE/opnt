<?php

include('includeHeader.inc.php');


 $username = $postData['username'];
 
 
//Added url optional ;
 if (!$username || $username == "" ) {
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{

  
    $json_arry=array();
        $q = "SELECT bringUUIDbyUsername(\"$username\");";
        $result = mysqli_query($db,$q);
        //echo $q;        
      if ($result == TRUE) {
        $val =array("status"=>"success");
			$json1['status'] =  $val['status'];
			while (($row = mysqli_fetch_assoc($result))){
				array_push($json_arry, $row); 	
			 } 
			http_response_code(200);
			$data['data']= $json_arry;
			$array3 = array_merge($json1, $data);
			print json_encode($array3);
      }
        else{
         echo  $response = "{\"status\": \"Username Exists\"}";
        }
     
}

?>
