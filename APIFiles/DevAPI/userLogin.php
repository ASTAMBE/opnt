<?php

 include('includeHeader.inc.php');


	$username = $_GET['username'];
	$password = $_GET['password'];

	if (!$username || $username == ""|| !$password || $password == ""){
 		 $response = "{\"status\": \"error\"}";
 	 	die($response);
	 }
	else{
  
//	$q = "SELECT USERID,COUNTRY_CODE from OPN_USERLIST WHERE USERNAME = \"$username\" AND PASSWORD = \"$password\"";
	$q = "SELECT U.USERID, U.COUNTRY_CODE, B.CARTORNOT
 from OPN_USERLIST U, (SELECT EXISTS (SELECT * FROM OPN_USER_CARTS WHERE USERID = (SELECT USERID FROM OPN_USERLIST WHERE USERNAME = \"$username\")) CARTORNOT) B
 WHERE U.USERNAME = \"$username\"  and AES_DECRYPT(U.password,'290317') =\"$password\";";
	$result = mysqli_query($db,$q);
//	echo $q;	
	
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

//	if (mysqli_num_rows($result) > 0) {
  //  		$row = mysqli_fetch_assoc($result);
    //		$userid = $row['USERID'];
    		//echo "{\"status\" : \"success\" , \"userid\":\"$userid \"}";
  //	}
  //	else {
    //		echo "{\"status\":\"error\",\"message\":\"Invalid username and password is not available\"}";
  //	}	
  //	$db=mysqli_close($db);
//	}

 

?>
