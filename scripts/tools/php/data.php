<?php
include('cors.php');
header('Content-Type: application/json');
session_start();
$rx[] = intval(@file_get_contents("/sys/class/net/INETFACE/statistics/rx_bytes"));
$tx[] = intval(@file_get_contents("/sys/class/net/INETFACE/statistics/tx_bytes"));
sleep(1);
$rx[] = intval(@file_get_contents("/sys/class/net/INETFACE/statistics/rx_bytes"));
$tx[] = intval(@file_get_contents("/sys/class/net/INETFACE/statistics/tx_bytes"));
$tbps = $tx[1] - $tx[0];
$rbps = $rx[1] - $rx[0];
$round_rx=round(($rbps*8)/10000000, 3);
$round_tx=round(($tbps*8)/10000000, 3);
//$round_rx=round($rbps/1024/1024, 1);
//$round_tx=round($tbps/1024/1024, 1);
$time=date("U")."000";
$_SESSION['rx'][] = "[$time, $round_rx]";
$_SESSION['tx'][] = "[$time, $round_tx]";
//$data['label'] = "1";
//$data['data'] = $_SESSION['rx'];
# to make sure that the graph shows only the
# last minute (saves some bandwitch to)

if (count($_SESSION['rx'])>60)
{
    $x = min(array_keys($_SESSION['rx']));
    unset($_SESSION['rx'][$x]);

    $x2 = min(array_keys($_SESSION['tx']));
    unset($_SESSION['tx'][$x2]);
}

// # json_encode didnt work, if you found a workarround pls write m
//echo json_encode($data, JSON_FORCE_OBJECT);

echo '[ { "data":['.implode( ",",$_SESSION['rx']).'],"label": "Download"}, ';
echo '{ "data":['.implode( ",",$_SESSION['tx']).'],"label": "Upload"} ';
echo ']';
?>
