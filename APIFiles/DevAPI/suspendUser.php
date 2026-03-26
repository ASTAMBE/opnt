<?php

include('includeHeader.inc.php');


  $username = $postData['username'];
  
    
  if (!$username || $username == "" ){
      	$response = "{\"status\": \"invalid parameters error\"}";
      	die($response);
    }
    else{
      
        $q = "call suspendUser(\"$username\");";

        $result = mysqli_query($db,$q);
        if($result == TRUE){
            $response = "{\"status\": \"success\", \"data\": \"$result\"}";
        }
        else{
            $response = "{\"status\": \"error\"}";
        }
    	echo $response;
    }
?>

