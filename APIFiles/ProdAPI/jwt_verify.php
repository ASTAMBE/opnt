<?php
  require 'jwt/vendor/autoload.php';
  use \Firebase\JWT\JWT;

function verify_jwt_by_userid($token,$userid){
	$Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
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
		   }
   }

   function verify_jwt_by_username($token,$username){
	$Secret_key = 'werkjhgfdzxcvlnm3poiuyt2r876f4gvkk4jek';
	   $decoded = JWT::decode($token, base64_decode(strtr($Secret_key, '-_', '+/')), ['HS256']);
	   $verify = json_decode(json_encode($decoded), true);
		   if (array_key_exists("status",$verify)){
			   return 0;
		   }else{
		   if($verify['username']==$username){
			   return 1;
		   }
		   else{
			   return 0;
		   }
		   }
   }
?>
