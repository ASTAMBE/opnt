<?php
include('includeHeader.inc.php');

 $username = $postData['username'];
 $uuid = $postData['userid'];
 if (!$username || $username == "" ||
      !$userid || $userid == ""  ) {
         $response = "{\"status\": \"error\"}";
        die($response);
 }
else{
    $token="sdhfkjlhjgfhgjhklj";
        $q = "call getUserData(\"$username\", \"$uuid\", \"$token\");";
        $result = mysqli_query($db,$q);
        //echo $q;        
      if ($result == TRUE) {
        $json_arry=array();
        $val =array("status"=>"success");
        $json1['status'] =  $val['status'];
        while (($row2 = mysqli_fetch_assoc($result))){
            array_push($json_arry, $row2); 	
            } 
        http_response_code(200);
        $data['data']= $json_arry;
        $array3 = array_merge($json1, $data);
        print json_encode($array3);
      }
        else{
         echo  $response = "{\"status\": \"Auth Failed\"}";
        }
     
}

?>
