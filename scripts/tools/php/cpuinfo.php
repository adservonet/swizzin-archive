<?php
include ('cors.php');

if (false === ($str = @file("/proc/cpuinfo"))) return false;
$str = implode("", $str);
@preg_match_all("/model\s+name\s{0,}\:+\s{0,}([^\:]+)([\r\n]+)/s", $str, $model);
@preg_match_all("/cpu\s+MHz\s{0,}\:+\s{0,}([\d\.]+)[\r\n]+/", $str, $mhz);
@preg_match_all("/cache\s+size\s{0,}\:+\s{0,}([\d\.]+\s{0,}[A-Z]+[\r\n]+)/", $str, $cache);

if (false !== is_array($model[1]))
{
    $num = sizeof($model[1]);
    if ($num == 1)
        $x1 = '';
    else
        $x1 = ' ×' . $num;
    echo $model[1][0] .'$'. $num .'$'. $mhz[1][0] .'$' . $cache[1][0] . "$" . $x1;
}
?>
