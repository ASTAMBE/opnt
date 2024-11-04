
<?php
  
     include ('dbconnection.inc');
   
             $username = $_GET['username'];
             $newPassword = $_GET['password'];
   
             if (!$username || $username == "" || !$newPassword || $newPassword == ""){
                      $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{



	                 $q = "UPDATE OPN_USERLIST SET PASSWORD = AES_ENCRYPT(\"$newPassword\", '290317') WHERE USERNAME = \"$username\";";

                    $result = mysqli_query($db,$q);
                    $response = "{\"status\": \"error\"}";
                    if($result == TRUE){

                        $response = "{\"status\": \"success\"}";

                    }
                   echo $response;

            }
  
  
  ?>
