<?php
include('includeHeader.inc.php');
$signed_request = $_POST['signed_request'];
$data = parse_signed_request($signed_request);
$fbuid = $data['user_id'];
$entrykey='fbremove';

// Start data deletion

// $status_url = 'https://www.<your_website>.com/deletion?id=abc123'; // URL to track the deletion
// $confirmation_code = 'abc123'; // unique code for the deletion request

// $data = array(
//   'url' => $status_url,
//   'confirmation_code' => $confirmation_code
// );
// echo json_encode($data);

if (!$fbuid || $fbuid == "" || !$entrykey || $entrykey == "" ){
    $response = "{\"status\": \"invalid parameters error\"}";
    die($response);
}
else{
 

  $q = "call fbUserRemoval(\"$fbuid\", \"$entrykey\");";

  $result = mysqli_query($db,$q);
  if($result == TRUE){
      $response = "{\"status\": \"success\"}";
  }
  else{
      $response = "{\"status\": \"error\"}";
  }
  echo $response;
}




function parse_signed_request($signed_request) {
  list($encoded_sig, $payload) = explode('.', $signed_request, 2);

  $secret = "b09d3384bd53145dbbdd6a6711392dc2"; // Use your app secret here

  // decode the data
  $sig = base64_url_decode($encoded_sig);
  $data = json_decode(base64_url_decode($payload), true);

  // confirm the signature
  $expected_sig = hash_hmac('sha256', $payload, $secret, $raw = true);
  if ($sig !== $expected_sig) {
    error_log('Bad Signed JSON signature!');
    return null;
  }

  return $data;
}

function base64_url_decode($input) {
  return base64_decode(strtr($input, '-_', '+/'));
}
?>