<?php
include ('cors.php');
require 'vendor/autoload.php';

$systemCtl = new SystemCtl\SystemCtl();
//$systemCtl->setBinary('/bin/systemctl');
//$systemCtl->setTimeout(10);

/*
function sff($f){
    $num = count(glob($f));
    if($num == 0) return false;
    else return true;
}
*/

function isEnabled($process, $username = false)
{
    global $systemCtl;

    $serv_exists = false;
//    $proc_exists = false;

    $service = false;
    $enabled = false;
    $active = false;

    if ($username) $username = "@".$username;

//    exec("ps axo user:20,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,comm,cmd| grep -iE $process | grep -v grep", $pids);
//    if (count($pids) > 0) $proc_exists = true;

    if(file_exists("/etc/systemd/system/multi-user.target.wants/".$process.$username.".service")) $serv_exists = true;
    if(file_exists("/sys/fs/cgroup/systemd/system.slice/".$process.$username.".service")) $serv_exists = true;
    if(file_exists("/etc/systemd/system/multi-user.target.wants/".$process.$username.".service")) $serv_exists = true;

    if ($serv_exists)
    {
        try {$service = $systemCtl->getService($process.$username);}
        catch (Exception $e) {$service = false; echo $e;}

        if ($service)
        {
            try {$enabled = $service->isEnabled();}
            catch (Exception $e) {$enabled = false;}

            if ($enabled)
            {
                try {$active = $service->isActive();}
                catch (Exception $e) {$active = false;}
            }

        }

        //echo $process ." exists: ".+$proc_exists ." active: ". +$active ." enabled: ". +$enabled ."\n";

        return array( "exists" => +$serv_exists, "enabled" => +$enabled, "active" => +$active );
    }
    return "";
}

$username = "seedit4me";
$apps = array(

    "openvpn2" => array(        isEnabled("openvpn")),
    "proftpd" => array(         isEnabled("proftpd")),
    "bazarr" => array(          isEnabled("bazarr")),
    "btsync" => array(          isEnabled("resilio-sync")),
    "deluged" => array(         isEnabled("deluged", $username)),
    "deluge" => array(          isEnabled("deluge-web", $username)),
    "emby" => array(            isEnabled("emby-server")),
    "filebrowser" => array(     isEnabled("filebrowser")),
    "flood" => array(           isEnabled("flood", $username)),
    "headphones" => array(      isEnabled("headphones")),
    "irssi" => array(           isEnabled("irssi", $username)),
    "lidarr" => array(          isEnabled("lidarr", $username)),
    "lounge" => array(          isEnabled("lounge")),
    "nzbget" => array(          isEnabled("nzbget", $username)),
    "nzbhydra" => array(        isEnabled("nzbhydra", $username)),
    "ombi" => array(            isEnabled("ombi")),
    "plex" => array(            isEnabled("plexmediaserver")),
    "plexpy" => array(          isEnabled("plexpy")),
    "tautulli" => array(        isEnabled("tautulli")),
    "pyload" => array(          isEnabled("pyload", $username)),
    "radarr" => array(          isEnabled("radarr")),
    "rutorrent" => array(       isEnabled("rtorrent", $username)),
    "sabnzbd" => array(         isEnabled("sabnzbd", $username)),
    "sickchill" => array(       isEnabled("sickchill", $username)),
    "medusa" => array(          isEnabled("medusa", $username)),
    "netdata" => array(         isEnabled("netdata")),
    "sonarr" => array(          isEnabled("sonarr", $username)),
    "subsonic" => array(        isEnabled("subsonic")),
    "syncthing" => array(       isEnabled("syncthing", $username)),
    "jackett" => array(         isEnabled("jackett", $username)),
    "couchpotato" => array(     isEnabled("couchpotato", $username)),
    "quassel" => array(         isEnabled("quasselcore")),
    "shellinabox" => array(     isEnabled("shellinabox")),
    "csf" => array(             isEnabled("csf")),
    "sickgear" => array(        isEnabled("sickgear", $username)),
    "znc" => array(             isEnabled("znc")),

);

echo json_encode($apps);

//isEnabled("rapidleech", $username)
//isEnabled("x2go", $username)




/*
case 66:
  $process = $_GET['serviceenable'];
    if ($process == "filebrowser"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "resilio-sync"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "shellinabox"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "emby-server"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "headphones"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "medusa"){
      shell_exec("sudo systemctl disable sickchill@$username");
      shell_exec("sudo systemctl stop sickchill@$username");
      shell_exec("sudo systemctl disable sickgear@$username");
      shell_exec("sudo systemctl stop sickgear@$username");
      shell_exec("sudo systemctl enable $process@$username");
      shell_exec("sudo systemctl start $process@$username");
    } elseif ($process == "netdata"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "nzbget"){
      shell_exec("sudo systemctl enable $process@$username");
      shell_exec("sudo systemctl start $process@$username");
    } elseif ($process == "plexmediaserver"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "tautulli"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "ombi"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "radarr"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } elseif ($process == "sickgear"){
      shell_exec("sudo systemctl disable medusa@$username");
      shell_exec("sudo systemctl stop medusa@$username");
      shell_exec("sudo systemctl disable sickchill@$username");
      shell_exec("sudo systemctl stop sickchill@$username");
      shell_exec("sudo systemctl enable $process@$username");
      shell_exec("sudo systemctl start $process@$username");
    } elseif ($process == "sickchill"){
      shell_exec("sudo systemctl disable medusa@$username");
      shell_exec("sudo systemctl stop medusa@$username");
      shell_exec("sudo systemctl disable sickgear@$username");
      shell_exec("sudo systemctl stop sickgear@$username");
      shell_exec("sudo systemctl enable $process@$username");
      shell_exec("sudo systemctl start $process@$username");
    } elseif ($process == "subsonic"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl start $process");
    } else {
      shell_exec("sudo systemctl enable $process@$username");
      shell_exec("sudo systemctl start $process@$username");
    }
  header('Location: https://' . $_SERVER['HTTP_HOST'] . '/');
break;

case 77:
  $process = $_GET['servicedisable'];
    if ($process == "filebrowser"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "resilio-sync"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "shellinabox"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "emby-server"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "headphones"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "lounge"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "netdata"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "plexmediaserver"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "tautulli"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "ombi"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "radarr"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } elseif ($process == "subsonic"){
      shell_exec("sudo systemctl stop $process");
      shell_exec("sudo systemctl disable $process");
    } else {
      shell_exec("sudo systemctl stop $process@$username");
      shell_exec("sudo systemctl disable $process@$username");
    }
  header('Location: https://' . $_SERVER['HTTP_HOST'] . '/');
break;


case 88:
  $process = $_GET['servicestart'];
    if ($process == "filebrowser"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "resilio-sync"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "shellinabox"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "emby-server"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "headphones"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "lounge"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "netdata"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "plexmediaserver"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "tautulli"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "ombi"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "radarr"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } elseif ($process == "subsonic"){
      shell_exec("sudo systemctl enable $process");
      shell_exec("sudo systemctl restart $process");
    } else {
      shell_exec("sudo systemctl restart $process@$username");
    }
  header('Location: https://' . $_SERVER['HTTP_HOST'] . '/');
break;


*/
?>
