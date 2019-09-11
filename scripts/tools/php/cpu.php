<?php
header('Content-Type: application/json');

// Timing
function microtime_float() {
  $mtime = microtime();
  $mtime = explode(' ', $mtime);
  return $mtime[1] + $mtime[0];
}

$loads = sys_getloadavg();
$core_nums = trim(shell_exec("grep -P '^processor' /proc/cpuinfo|wc -l"));
$load = round($loads[0]/($core_nums + 1)*100, 2);

$out = array("cpu" => $load);

echo json_encode($out);
?>
