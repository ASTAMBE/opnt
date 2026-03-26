<?php
require 'jwt/vendor/autoload.php';
use \Firebase\JWT\JWT;
include('includeHeader.inc.php');

// --- Logging block ---
$raw_input = file_get_contents("php://input");
$decoded_json = json_encode(json_decode($raw_input, true)); // Ensures clean formatting
$client_ip = $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN';
$headers = json_encode(getallheaders());
$endpoint = "loginWithGoogleUserApp.php";

// Call logging stored proc
$log_sql = "CALL logAPICalls('$endpoint', '$client_ip', '$headers', '$raw_input', '$decoded_json');";
mysqli_query($db, $log_sql);
// --- End logging block ---

$Google_userid = $postData['Google_userid'];
$device_serial = $postData['device_serial'];

if (!$Google_userid || $Google_userid == "" || !$device_serial || $device_serial == "") {
    $response = "{\"status\": \"error\"}";
    die($response);
} else {
    $q = "CALL loginWithGoogleUserApp(\"$Google_userid\", \"$device_serial\");";
    $result = mysqli_query($db, $q);

    if ($result == TRUE) {
        while (($row = mysqli_fetch_assoc($result))) {
            $starttime = time();
            $exptime = time() + (14 * 24 * 60 * 60);
            $token_payload = [
                'uuid' => $row['USERID'],
                'username' => $row['USERNAME'],
                'country_code' => $row['COUNTRY_CODE'],
                "iat" => $starttime,
                "exp" => $exptime
            ];
            $jwt = JWT::encode($token_payload, base64_decode(strtr($Secret_key, '-_', '+/')), 'HS256');
            $row['token'] = $jwt;
            $json_arry[] = $row;
        }
        $r = json_encode($json_arry);
        echo $r;
    } else {
        $response = "{\"status\": \"error\"}";
        echo $response;
    }
}
?>
