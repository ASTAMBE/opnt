<?php
include('includeHeader.inc.php');

$url = $postData['url'];

// procedure to check
$sql = "CALL checkURL(\"$url\")";
$response = mysqli_query($db,$sql);

$json_array = array();

if($response == TRUE) {
    $num_rows = $response->num_rows;

    if($num_rows == 0) {
        
            $response = "{\"status\": \"not found\"}";
            die($response);

    } else {

        while ($db_obj = $response->fetch_object()) {
            $json_array[] = object_to_array($db_obj);
        }

        echo json_encode($json_array);
    }

}

function object_to_array($data) {
    if (is_array($data) || is_object($data)) {
        $result = array();
        foreach ($data as $key => $value) {
            $result[$key] = object_to_array($value);
        }
        return $result;
    }
    return $data;
}
?>