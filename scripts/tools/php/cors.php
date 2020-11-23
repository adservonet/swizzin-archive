<?php

//if($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
//	header('Content-Type', 'application/json');
	header('Access-Control-Allow-Origin: ' . $_SERVER["HTTP_ORIGIN"]);
	header('Access-Control-Allow-Credentials: true');
	header('Access-Control-Max-Age: 60');
	header('Access-Control-Allow-Headers: AccountKey,x-requested-with, x-csrf-token, Content-Type, origin, authorization, accept, client-security-token, host, date, cookie, cookie2');
	header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
//}
//if($_SERVER['REQUEST_METHOD'] == 'OPTIONS') die();
//header('Access-Control-Allow-Origin: *');
//header('Access-Control-Allow-Credentials: true');
//header('Access-Control-Allow-Methods: *');
//header('Access-Control-Allow-Headers: Authorization,DNT,User-Agent,Keep-Alive,Content-Type,accept,origin,X-Requested-With,X-CSRF-Token');
//header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
//header("Cache-Control: post-check=0, pre-check=0", false);
//header("Pragma: no-cache");

//we have all these in the nginx config now
?>
