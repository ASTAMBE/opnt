<?php
    /// Programmer Rohit Kansay // Antino Labs
 
    include('CreateConnection.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: J.4O8SGQFNM%ZJR't8wX99y5a=X0/F");

    $today = date("mdY_Hi");  
     $str="ALL".$today;
     $STPquery= "CALL STP_MONITOR(\"$str\")"; 
     $result = mysqli_query($db,$STPquery); 
     if($result == TRUE)
     {
         $rtn = array (
          "status"=> "200",
          "message"=>  "Success STP_MONITOR Filename=".$str."");
      http_response_code(200);
      print json_encode($rtn);
     }else{
         $rtn = array (
          "status"=> "500",
          "error"=> "something wrong With STP_MONITER");
      http_response_code(500);
      print json_encode($rtn);
     }
     ?>