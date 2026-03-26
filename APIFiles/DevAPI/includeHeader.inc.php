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




?>