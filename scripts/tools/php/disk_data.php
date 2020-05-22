<?php
include('cors.php');
header('Content-Type: text/plain');

$dir = "/home";  //"/";

//hard disk
$dftotal = (round(@disk_total_space($dir)/(1024*1024*1024),1)); //Total
$dffree = (round(@disk_free_space($dir)/(1024*1024*1024),1)); //Available
$dfused = (round(@disk_total_space($dir)/(1024*1024*1024),1)-round(@disk_free_space($dir)/(1024*1024*1024),1)); //used

echo $dffree ."$". $dfused ."$". $dftotal
?>
