<?php
include('includeHeader.inc.php');
$userid = $_POST['userid'];
 $contentID = $_POST['contentID'];
 $contentType = $_POST['contentType'];
 $reportTypeCode = $_POST['reportTypeCode'];
 $userComment = addslashes($_POST['userComment']);

if (!$userid || $userid == "" || !$contentID || $contentID=="" || !$contentType || $contentType == "" ||  !$reportTypeCode || $reportTypeCode == ""){
    $response =array("status"=>"error");
    http_response_code(500);
    print json_encode($response );
}
else{
    $q = "CALL userContentReport(\"$userid\",\"$contentID\",\"$contentType\",\"$reportTypeCode\",\"$userComment\");";
	$result = mysqli_query($db,$q);
	if($result == TRUE){
        $response =array("status"=>"success");
        http_response_code(200);
        print json_encode($response );
	}
	else{
        $response =array("status"=>"error");
        http_response_code(500);
        print json_encode($response );
	}
}