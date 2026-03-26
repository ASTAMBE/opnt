<?php
include('includeHeader.inc.php');
include('jwt_verify.php');
header('Content-type: application/json');

$uuid      = $postData['userid'];
$token = $headers['Token'];
if ($uuid == "" || $token == ""){
    $response = "{\"status\": \"error\", \"message\": \"parameter missing\"}";
    die($response);
}
else 
{
	if($verify=verify_jwt_by_userid($token,$uuid)){
    }else{
        $response =array("status"=>"Authentication Failed");
        http_response_code(401);
        print json_encode($response);
        die();
    }


$q = "call myActivity(\"$uuid\");";
$json_arry = array();
$json_arry1 = array();
$result = mysqli_query($db,$q);
$rowCount=mysqli_num_rows($result); 
if($rowCount > 0){
    $val =array("status"=>"success");
    $json1['status'] =  $val['status'];
    while ($row = mysqli_fetch_assoc($result)){
        $json_arry1['TOPICID'] = $row['TOPICID'];
        $json_arry1['TOPIC'] = $row['TOPIC'];
        $json_arry1['PC_DELTA'] = $row['PC_DELTA'];
        $json_arry1['NETSIZE'] = $row['NETSIZE'];
        $json_arry1['POST_COUNT'] = $row['POST_COUNT'];
        $json_arry1['COMMENT_COUNT'] = $row['COMMENT_COUNT'];
        $json_arry1['CHF'] = $row['CHF'];
        $json_arry1['BKMK_COUNT'] = $row['BKMK_COUNT'];


        
      array_push($json_arry,$json_arry1); 	
	// print_r($row);
	// echo 'test';
    } 
    http_response_code(200);
    $data['data']= $json_arry;
    $array3 = array_merge($json1, $data);
    print json_encode($array3);
    
}
else{
    $response =array("status"=>"error", "message"=>"data not found");
    $json_arry[] =  $response;
    http_response_code(500);
    print json_encode($json_arry);
}
	
}



?>