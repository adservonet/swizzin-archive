<?php
include('cors.php');
header('Content-Type: text/plain');

// Network Interface
$interface = system('ip link | awk -F: \'$0 !~ "lo|tun|vir|wl|^[^0-9]"{print $2;getline}\' | cut -d @ -f 1 | xargs');
$iface = $interface;//INETFACE;
$iface_list = array($interface);
$iface_title[$interface] = 'External';
$vnstat_bin = '/usr/bin/vnstat';
$data_dir = './dumps';
$byte_notation = null;

function get_vnstat_data($use_label=true) {
    global $iface, $vnstat_bin, $data_dir;
    global $hour,$day,$month,$top,$summary;
    $vnstat_data = array();
    if (!isset($vnstat_bin) || $vnstat_bin == '') {
        if (file_exists("$data_dir/vnstat_dump_$iface")) {
            $vnstat_data = file("$data_dir/vnstat_dump_$iface");
        }
    } else {
        $fd = popen("$vnstat_bin --dumpdb -i $iface", "r");
        if (is_resource($fd)) {
            $buffer = '';
            while (!feof($fd)) {
                $buffer .= fgets($fd);
            }
            $vnstat_data = explode("\n", $buffer);
            pclose($fd);
        }
    }

    $day = array();
    $hour = array();
    $month = array();
    $top = array();

    if (isset($vnstat_data[0]) && strpos($vnstat_data[0], 'Error') !== false) {
        return;
    }

    //
    // extract data
    //
    foreach($vnstat_data as $line) {
        $d = explode(';', trim($line));
        if ($d[0] == 'd') {
            $day[$d[1]]['time']  = $d[2];
            $day[$d[1]]['rx']    = $d[3] * 1024 + $d[5];
            $day[$d[1]]['tx']    = $d[4] * 1024 + $d[6];
            $day[$d[1]]['act']   = $d[7];
            if ($d[2] != 0 && $use_label) {
                $day[$d[1]]['label'] = strftime('%d %B',$d[2]);
                $day[$d[1]]['img_label'] = strftime('%d', $d[2]);
            } elseif($use_label) {
                $day[$d[1]]['label'] = '';
                $day[$d[1]]['img_label'] = '';
            }
        } else if ($d[0] == 'm') {
            $month[$d[1]]['time'] = $d[2];
            $month[$d[1]]['rx']   = $d[3] * 1024 + $d[5];
            $month[$d[1]]['tx']   = $d[4] * 1024 + $d[6];
            $month[$d[1]]['act']  = $d[7];
            if ($d[2] != 0 && $use_label) {
                $month[$d[1]]['label'] = strftime('%B %Y', $d[2]);
                $month[$d[1]]['img_label'] = strftime('%b', $d[2]);
            } else if ($use_label) {
                $month[$d[1]]['label'] = '';
                $month[$d[1]]['img_label'] = '';
            }
        } else if ($d[0] == 'h') {
            $hour[$d[1]]['time'] = $d[2];
            $hour[$d[1]]['rx']   = $d[3];
            $hour[$d[1]]['tx']   = $d[4];
            $hour[$d[1]]['act']  = 1;
            if ($d[2] != 0 && $use_label) {
                $st = $d[2] - ($d[2] % 3600);
                $et = $st + 3600;
                $hour[$d[1]]['label'] = strftime('%l%p', $st).' - '.strftime('%l%p', $et);
                $hour[$d[1]]['img_label'] = strftime( '%l', $d[2]);
            } else if ($use_label) {
                $hour[$d[1]]['label'] = '';
                $hour[$d[1]]['img_label'] = '';
            }
        } else if ($d[0] == 't') {
            $top[$d[1]]['time'] = $d[2];
            $top[$d[1]]['rx']   = $d[3] * 1024 + $d[5];
            $top[$d[1]]['tx']   = $d[4] * 1024 + $d[6];
            $top[$d[1]]['act']  = $d[7];
            if($use_label) {
                $top[$d[1]]['label'] = strftime('%d %B %Y', $d[2]);
                $top[$d[1]]['img_label'] = '';
            }
        } else {
            $summary[$d[0]] = isset($d[1]) ? $d[1] : '';
        }
    }

    rsort($day);
    rsort($month);
    rsort($hour);
}

function kbytes_to_string($kb) {

  global $byte_notation;

  $units = array('TB','GB','MB','KB');
  $scale = 1024*1024*1024;
  $ui = 0;

  $custom_size = isset($byte_notation) && in_array($byte_notation, $units);

  while ((($kb < $scale) && ($scale > 1)) || $custom_size) {
    $ui++;
    $scale = $scale / 1024;

    if ($custom_size && $units[$ui] == $byte_notation) {
      break;
    }
  }

  return sprintf("%0.2f %s", ($kb/$scale),$units[$ui]);
}

function write_summary_s() {
  global $summary,$day,$hour,$month;

  $trx = $summary['totalrx']*1024+$summary['totalrxk'];
  $ttx = $summary['totaltx']*1024+$summary['totaltxk'];

  $sum = array();

  if (count($day) > 0 && count($hour) > 0 && count($month) > 0) {
    $sum[0]['act'] = 1;
    $sum[0]['label'] = 'This hour';
    $sum[0]['rx'] = $hour[0]['rx'];
    $sum[0]['tx'] = $hour[0]['tx'];

    $sum[1]['act'] = 1;
    $sum[1]['label'] = 'This day';
    $sum[1]['rx'] = $day[0]['rx'];
    $sum[1]['tx'] = $day[0]['tx'];

    $sum[2]['act'] = 1;
    $sum[2]['label'] = 'This month';
    $sum[2]['rx'] = $month[0]['rx'];
    $sum[2]['tx'] = $month[0]['tx'];

    $sum[3]['act'] = 1;
    $sum[3]['label'] = 'All time';
    $sum[3]['rx'] = $trx;
    $sum[3]['tx'] = $ttx;
  }

 return write_data_table_s($sum);

}

function write_summary_t() {
    global $top;
    return write_data_table_t($top);
}

function write_data_table_s($tab) {
  $r = [];
  for ($i=0; $i<count($tab); $i++) {
    if ($tab[$i]['act'] == 1) {
      $rx = kbytes_to_string($tab[$i]['rx']);
      $tx = kbytes_to_string($tab[$i]['tx']);
      $total = kbytes_to_string($tab[$i]['rx']+$tab[$i]['tx']);
        array_push($r,[ "out"=>$tx,"in"=>$rx,"total"=>$total]);
    }
  }
  return $r;
}

function write_data_table_t($tab) {
  $r = [];
  for ($i=0; $i<count($tab); $i++) {
    if ($tab[$i]['act'] == 1) {
      $t = $tab[$i]['label'];
      $rx = kbytes_to_string($tab[$i]['rx']);
      $tx = kbytes_to_string($tab[$i]['tx']);
      $total = kbytes_to_string($tab[$i]['rx']+$tab[$i]['tx']);
        array_push($r,[ "label"=>$t,"out"=>$tx,"in"=>$rx,"total"=>$total]);
    }
  }
  return $r;
}

function tadata() {
    global $summary;
    $trx = $summary['totalrx']*1024+$summary['totalrxk'];
    $ttx = $summary['totaltx']*1024+$summary['totaltxk'];
    return array ("trx" => $trx,"ttx" =>$ttx);
}

get_vnstat_data();

$s = [ "total" => write_summary_s(), "h" => write_data_table_s($hour), "d" => write_data_table_s($day), "m" => write_data_table_s($month)];
$t = [ "top10d" => write_summary_t(), "h" => write_data_table_t($hour), "d" => write_data_table_t($day), "m" => write_data_table_t($month)];
$ta = [ "tadata" => tadata()];
$bw = array ("summary" => $s,"top" =>$t, "ta" => $ta);
echo json_encode($bw);