<?php
include('includeHeader.inc.php');



$getuserFrom     = $postData['userFrom'];
$getuserTo       = $postData['userTo'];
$getpostid       = $postData['postid'];
// $gettopicid      = $postData['topicid'];
// 05 feb2021 AST: Removing topicid from input params
$uType      = $postData['uType'];

if ($getuserFrom == "" || $getuserTo == "" || $getpostid == "" ){
    $response = "{\"status\": \"error\"}";
    die($response);
}
else 
{
	

$q = "call copyUserCarts2(\"$getuserFrom\", \"$getuserTo\", \"$getpostid\",\"$uType\");";
$json_arry = array();
$json_arry1 = array();
$result = mysqli_query($db,$q);
if($result == TRUE){
    $val =array("status"=>"success");
    $json1['status'] =  $val['status'];
    while (($row = mysqli_fetch_assoc($result))){
        $json_arry1['uuidTo'] = $row['uuidTo'];
        $json_arry1['TIDTO'] = $row['TIDTO'];
        if($row['postID']){
            $json_arry1['postID'] = $row['postID'];
        }
        else{
            $json_arry1['postID'] = $row['0'];
        }
      array_push($json_arry,$json_arry1); 	
    } 
    http_response_code(200);
    $data['data']= $json_arry;
    $array3 = array_merge($json1, $data);
    print json_encode($array3);
}
else{
    $response =array("status"=>"error");
    $json_arry[] =  $response;
    http_response_code(500);
    print json_encode($json_arry);
}
	
}



?>