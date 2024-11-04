
<?php

include('includeHeader.inc.php');


$username = $postData['username'];
$newPassword = $postData['password'];
$answer = $postData['answer'];
//

//if (!$username || $username == "" || !$newPassword || $newPassword == ""|| !$answer || $answer == ""){
  //$response = "{\"status\": \"No or Wrong Inputs\"}";
  //die($response);
//}
//else{


  $q = "call cnp(\"$username\", \"$newPassword\", \"$answer\");";

  $result = mysqli_query($db,$q);

  if($result == TRUE){

    $response = "{\"status\": \"success\"}";

  }else{
      $response = "{\"status\": \"Wrong Answer\"}";
  }
  echo $response;

//}


?>
