<?php
  
     include ('dbconnection.inc');
   
             $userid = $_GET['username'];
   
             if (!$userid || $userid == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{



	$q = "SELECT PASSWORD_Q, PASSWORD_Q_A FROM OPN_USERLIST WHERE USERNAME = \"$userid\";";

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
