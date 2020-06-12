<?php
include('cors.php');
//header('Content-Type: text/plain');

// Timing
function microtime_float() {
  $mtime = microtime();
  $mtime = explode(' ', $mtime);
  return $mtime[1] + $mtime[0];
}

$loads = sys_getloadavg();
$core_nums = trim(shell_exec("grep -P '^siblings' /proc/cpuinfo | awk '{print $3}' | head -n 1"));
$load = round($loads[0]/($core_nums + 1)*100, 2);

$out = array("cpu" => $load);

echo json_encode($out);
?>
