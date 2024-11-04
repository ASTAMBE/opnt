<?php
include('includeHeader.inc.php');
include('jwt_verify.php');
header('Content-type: application/json');

$uuid      = $postData['userid'];
$postid      = $postData['postid'];
$token = $headers['Token'];
if ($uuid == "" || $postid == "" || $token == ""){
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


$q = "call postBookmark(\"$uuid\", \"$postid\");";
$result = mysqli_query($db,$q);
$response='';
$rowCount=mysqli_num_rows($result);
if($rowCount > 0){
    $response = "{\"status\": \"success\", \"message\": \"bookmark created successfully\" }";
    http_response_code(200);
    
}
else{
    $response = "{\"status\": \"error\", \"message\": \"bookmark could not be created\"}";
    http_response_code(500);
}


echo $response;

	
}



?>