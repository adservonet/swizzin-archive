<?php
header('Content-Type: text/plain');

switch(PHP_OS)
{
  case "Linux":
    $sysInfo = sys_linux();
  break;

  case "FreeBSD":
    $sysInfo = sys_freebsd();
  break;

  default:
  break;
}

//linux system detects
function sys_linux() {
    // LOAD AVG
    if (false === ($str = @file("/proc/loadavg"))) return false;
    $str = explode(" ", implode("", $str));
    $str = array_chunk($str, 4);
    $res['loadAvg'] = implode("$", $str[0]);
    return $res;
}

echo $sysInfo['loadAvg'];
?>
