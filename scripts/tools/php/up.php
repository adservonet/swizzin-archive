<?php
include ('cors.php');
$uptime = shell_exec("cut -d. -f1 /proc/uptime");
$days = floor($uptime/60/60/24);
$hours = int($uptime)/60/60%24;
$mins = int($uptime)/60%60;
$secs = int($uptime)%60;
echo $days."$".$hours."$".$mins."$".$secs;
?>

