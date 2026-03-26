<?php
  //get environment from .htaccess file
  $apiEnv = getenv("API_ENV");

  //get config based on env
  include('../../config.' . $apiEnv . '/dbconnection.inc');
  include('../../config.' . $apiEnv . '/util.php');

  //get headers
  $headers = parseRequestHeaders();

  //get data from request body
  $postData = getPostData();

?>