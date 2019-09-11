<?php
include ('cors.php');
header('Content-Type: text/plain');

// Information obtained depending on the system CPU
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
function sys_linux()
{
    // MEMORY
    if (false === ($str = @file("/proc/meminfo"))) return false;
    $str = implode("", $str);
    preg_match_all("/MemTotal\s{0,}\:+\s{0,}([\d\.]+).+?MemFree\s{0,}\:+\s{0,}([\d\.]+).+?Cached\s{0,}\:+\s{0,}([\d\.]+).+?SwapTotal\s{0,}\:+\s{0,}([\d\.]+).+?SwapFree\s{0,}\:+\s{0,}([\d\.]+)/s", $str, $buf);
  preg_match_all("/Buffers\s{0,}\:+\s{0,}([\d\.]+)/s", $str, $buffers);

    $res['memTotal'] = round($buf[1][0]/1024, 2);
    $res['memFree'] = round($buf[2][0]/1024, 2);
    $res['memBuffers'] = round($buffers[1][0]/1024, 2);
    $res['memCached'] = round($buf[3][0]/1024, 2);
    $res['memUsed'] = $res['memTotal']-$res['memFree'];
    $res['memPercent'] = (floatval($res['memTotal'])!=0)?round($res['memUsed']/$res['memTotal']*100,2):0;

    $res['memRealUsed'] = $res['memTotal'] - $res['memFree'] - $res['memCached'] - $res['memBuffers']; //Real memory usage
    $res['memRealFree'] = $res['memTotal'] - $res['memRealUsed']; //Real idle
    $res['memRealPercent'] = (floatval($res['memTotal'])!=0)?round($res['memRealUsed']/$res['memTotal']*100,2):0; //Real memory usage

    $res['memCachedPercent'] = (floatval($res['memCached'])!=0)?round($res['memCached']/$res['memTotal']*100,2):0; //Cached memory usage

    $res['swapTotal'] = round($buf[4][0]/1024, 2);
    $res['swapFree'] = round($buf[5][0]/1024, 2);
    $res['swapUsed'] = round($res['swapTotal']-$res['swapFree'], 2);
    $res['swapPercent'] = (floatval($res['swapTotal'])!=0)?round($res['swapUsed']/$res['swapTotal']*100,2):0;
    return $res;
}

//FreeBSD system detects
function sys_freebsd()
{
  //MEMORY
  if (false === ($buf = get_key("hw.physmem"))) return false;
  $res['memTotal'] = round($buf/1024/1024, 2);

  $str = get_key("vm.vmtotal");
  preg_match_all("/\nVirtual Memory[\:\s]*\(Total[\:\s]*([\d]+)K[\,\s]*Active[\:\s]*([\d]+)K\)\n/i", $str, $buff, PREG_SET_ORDER);
  preg_match_all("/\nReal Memory[\:\s]*\(Total[\:\s]*([\d]+)K[\,\s]*Active[\:\s]*([\d]+)K\)\n/i", $str, $buf, PREG_SET_ORDER);

  $res['memRealUsed'] = round($buf[0][2]/1024, 2);
  $res['memCached'] = round($buff[0][2]/1024, 2);
  $res['memUsed'] = round($buf[0][1]/1024, 2) + $res['memCached'];
  $res['memFree'] = $res['memTotal'] - $res['memUsed'];
  $res['memPercent'] = (floatval($res['memTotal'])!=0)?round($res['memUsed']/$res['memTotal']*100,2):0;

  $res['memRealPercent'] = (floatval($res['memTotal'])!=0)?round($res['memRealUsed']/$res['memTotal']*100,2):0;

  return $res;
}

//Obtain the parameter values FreeBSD
function get_key($keyName)
{
  return do_command('sysctl', "-n $keyName");
}

//Determining the location of the executable file FreeBSD
function find_command($commandName)
{
  $path = array('/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin');
  foreach($path as $p)
  {
    if (@is_executable("$p/$commandName")) return "$p/$commandName";
  }
  return false;
}

//Order Execution System FreeBSD
function do_command($commandName, $args)
{
  $buffer = "";
  if (false === ($command = find_command($commandName))) return false;
  if ($fp = @popen("$command $args", 'r'))
  {
    while (!@feof($fp))
    {
      $buffer .= @fgets($fp, 4096);
    }
    return trim($buffer);
  }
  return false;
}

//Determine if memory is less than 1GB, will be displayed MB, otherwise display GB Unit
if($sysInfo['memTotal']<1024)
{
  $memTotal = $sysInfo['memTotal']." MB";
  $mt = $sysInfo['memTotal']." MB";
  $mu = $sysInfo['memUsed']." MB";
  $mf = $sysInfo['memFree']." MB";
  $mc = $sysInfo['memCached']." MB"; //memory cache
  $mb = $sysInfo['memBuffers']." MB";  //buffer
  $st = $sysInfo['swapTotal']." MB";
  $su = $sysInfo['swapUsed']." MB";
  $sf = $sysInfo['swapFree']." MB";
  $swapPercent = $sysInfo['swapPercent'];
  $memRealUsed = $sysInfo['memRealUsed']." MB"; //Real memory usage
  $memRealFree = $sysInfo['memRealFree']." MB"; //Real memory free
  $memRealPercent = $sysInfo['memRealPercent']; //Real memory usage ratio
  $memPercent = $sysInfo['memPercent']; //Total Memory Usage
  $memCachedPercent = $sysInfo['memCachedPercent']; //cache memory usage
}
else
{
  $memTotal = round($sysInfo['memTotal']/1024,3)." GB";
  $mt = round($sysInfo['memTotal']/1024,3)." GB";
  $mu = round($sysInfo['memUsed']/1024,3)." GB";
  $mf = round($sysInfo['memFree']/1024,3)." GB";
  $mc = round($sysInfo['memCached']/1024,3)." GB";
  $mb = round($sysInfo['memBuffers']/1024,3)." GB";
  $st = round($sysInfo['swapTotal']/1024,3)." GB";
  $su = round($sysInfo['swapUsed']/1024,3)." GB";
  $sf = round($sysInfo['swapFree']/1024,3)." GB";
  $swapPercent = $sysInfo['swapPercent'];
  $memRealUsed = round($sysInfo['memRealUsed']/1024,3)." GB"; //Real memory usage
  $memRealFree = round($sysInfo['memRealFree']/1024,3)." GB"; //Real memory free
  $memRealPercent = $sysInfo['memRealPercent']; //Real memory usage ratio
  $memPercent = $sysInfo['memPercent']; //Total Memory Usage
  $memCachedPercent = $sysInfo['memCachedPercent']; //cache memory usage
}

$tmp = array(
    'memTotal', 'memUsed', 'memFree', 'memPercent',
    'memCached', 'memRealPercent',
    'swapTotal', 'swapUsed', 'swapFree', 'swapPercent'
);
foreach ($tmp AS $v) {
    $sysInfo[$v] = $sysInfo[$v] ? $sysInfo[$v] : 0;
}

echo $memPercent ."$". $mt ."$". $mu ."$". $mf ."$";

if($sysInfo['memCached']>0)
{
    echo $memCachedPercent ."$". $mc ."$". $mb ."$";
    echo $memRealPercent ."$". $memRealUsed ."$". $memRealFree ."$";
}

if($sysInfo['swapTotal']>0)
{
    echo $swapPercent ."$". $st ."$". $su ."$". $sf ."$". $memTotal;
}
?>
