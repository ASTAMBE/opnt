<?php
            include ('dbconnection.inc');
  
             $username = $_GET['username'];
             $country_code = $_GET['country_code'];
             $fb_username = $_GET['fb_username'];
             $fb_userid = $_GET['fb_userid'];

             if (!$username || $username == "" ||
                  !$country_code || $country_code == ""){
                     $response = "{\"status\": \"error\"}";
                    die($response);
             }
            else{
                    $q = "INSERT INTO OPN_USERLIST(USERNAME, CREATION_DATE, COUNTRY_CODE, FB_USER_NAME, FB_USERID, FB_USER_FLAG)
VALUES (\"$username\", NOW(), \"$country_code\", \"$fb_username\", \"$fb_userid\", 'Y');" ;
                    $result = mysqli_query($db,$q);
//                  echo $q;        
                  if ($result == TRUE) {
                            $response = "{\"status\": \"success\"}";
                     }
                    else{
                            $response = "{\"status\": \"error\"}";
                    }
                    echo $response;
            }
  
  
    ?>
