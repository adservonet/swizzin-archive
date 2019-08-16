<?php
/**
 * Created by PhpStorm.
 * User: Prime
 * Date: 09.08.2019
 * Time: 14:32
 */
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Max-Age: 1000');
header('Access-Control-Allow-Headers: Content-Type');
echo json_encode(array("your_request_was" => $_POST['my_request_is']));

die();
?>