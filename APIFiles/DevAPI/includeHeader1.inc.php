<?php
  //get environment from .htaccess file
  $apiEnv = getenv("API_ENV");

  //get config based on env
  include('../../config.' . $apiEnv . '/dbconnection.inc');
  include('../../config.' . $apiEnv . '/util.php');
  require 'jwt/vendor/autoload.php';
  use \Firebase\JWT\JWT;
  $Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
  //get headers
  $headers = parseRequestHeaders();

  //authenticate access key
  if (!authenticateGet($headers)){
    header("HTTP/1.1 401 Unauthorized");
    die();
  }

  //get data from request body
  $postData = getPostData();


$url = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] 
                === 'on' ? "https" : "http") . "://" . 
          $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF']; 
$val=parse_url($url, PHP_URL_PATH);
$list = array("/api.$apiEnv/includeHeader1.inc.php","/api.$apiEnv/loginWithFBUserApp.php","/api.$apiEnv/createFBUserTokenApp.php",
"/api.$apiEnv/loginWithGoogleUserApp.php","/api.$apiEnv/createGoogleUserTokenApp.php","/api.$apiEnv/convertGuestUserAppNew.php");

if (in_array($val, $list)){
}else{
if(empty($postData)){
	$response =array("status"=>"Authentication Failed");
	http_response_code(401);
	die(json_encode($response));
} else{
	jwt_verifier($postData);
}
}

function getBearerToken() {
    $headers = getAuthorizationHeader();
    // HEADER: Get the access token from the header
    if (!empty($headers)) {
        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            return $matches[1];
        }
    }
    return null;
}
function getAuthorizationHeader(){
	$headers = null;
	if (isset($_SERVER['Authorization'])) {
		$headers = trim($_SERVER["Authorization"]);
	}
	else if (isset($_SERVER['HTTP_AUTHORIZATION'])) { //Nginx or fast CGI
		$headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
	} elseif (function_exists('apache_request_headers')) {
		$requestHeaders = apache_request_headers();
		// Server-side fix for bug in old Android versions (a nice side-effect of this fix means we don't care about capitalization for Authorization)
		$requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
		//print_r($requestHeaders);
		if (isset($requestHeaders['Authorization'])) {
			$headers = trim($requestHeaders['Authorization']);
		}
	}
	return $headers;
}

function verify_jwt($token,$userid){
	$Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
	try{
	   $decoded = JWT::decode($token, base64_decode(strtr($Secret_key, '-_', '+/')), ['HS256']);
	   $verify = json_decode(json_encode($decoded), true);
		   if (array_key_exists("status",$verify)){
			   return 0;
		   }else{
		   if($verify['uuid']==$userid){
			   return 1;
		   }
		   else{
			   return 0;
		   }
		   }}
		   catch (Exception $e) {
			return 0;
		}
   }

function jwt_verifier($postData){
	$token=getBearerToken();
	$userid = $postData['userid'];
	if (isset($token) && isset($userid)){
	if($verify=verify_jwt($token,$userid)){
		
		}else{
			$response =array("status"=>"Authentication Failed");
			http_response_code(401);
                        echo $response=  json_encode($response);
			die();
		}
	}else{
		$response =array("status"=>"Authentication Failed");
		http_response_code(401);
                echo $response=  json_encode($response);
		die();
	}
}

?>