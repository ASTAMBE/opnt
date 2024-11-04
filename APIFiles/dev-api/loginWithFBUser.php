<?php
            include ('dbconnection.inc');
 
             $fb_userid = $_GET['fb_userid'];

             if (!$fb_userid|| $fb_userid == ""){
                     $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{
            		$q = "SELECT USERID, USERNAME, COUNTRY_CODE FROM OPN_USERLIST WHERE FB_USERID = \"$fb_userid\";";
                    $result = mysqli_query($db,$q);
  //                echo $q;        
                  
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
