<?php
include ('cors.php');

function sff($f){
    $num = count(glob($f));
    if($num == 0) return false;
    else return true;
}

function isEnabled($process, $username){
    if(sff("/etc/systemd/system/multi-user.target.wants/".$process."*.service")) return 1;
    if(sff("/sys/fs/cgroup/systemd/system.slice/".$process."*.service")) return 1;
    if(sff("/etc/systemd/system/multi-user.target.wants/".$process."*.service")) return 1;
    return 0;
}

function processExists($processName, $username) {
    $exists= 0;
    //exec("ps axo user:20,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,comm,cmd|grep $username | grep -iE $processName | grep -v grep", $pids);
    exec("ps axo user:20,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,comm,cmd| grep -iE $processName | grep -v grep", $pids);
    if (count($pids) > 0) {
        $exists = 1;
    }
    return $exists;
}

$username = "seedit4me";
$apps = array(

    "openvpn2" => array( "exists" => processExists("openvpn",$username), "enabled" => isEnabled("openvpn",$username) ),
    "proftpd" => array( "exists" => processExists("proftpd",$username), "enabled" => isEnabled("proftpd",$username) ),
    "bazarr" => array( "exists" => processExists("bazarr",$username), "enabled" => isEnabled("bazarr",$username) ),
    "btsync" => array( "exists" => processExists("resilio-sync","rslsync"), "enabled" => isEnabled("resilio-sync","rslsync") ),
    "deluged" => array( "exists" => processExists("deluged",$username), "enabled" => isEnabled("deluged", $username) ),
    "deluge" => array( "exists" => processExists("deluge-web",$username), "enabled" => isEnabled("deluge-web", $username) ),
    "emby" => array( "exists" => processExists("EmbyServer","emby"), "enabled" => isEnabled("emby-server", $username) ),
    "filebrowser" => array( "exists" => processExists("filebrowser",$username), "enabled" => isEnabled("filebrowser", $username) ),
    "flood" => array( "exists" => processExists("flood",$username), "enabled" => isEnabled("flood", $username) ),
    "headphones" => array( "exists" => processExists("headphones",$username), "enabled" => isEnabled("headphones", $username) ),
    "irssi" => array( "exists" => processExists("irssi",$username), "enabled" => isEnabled("irssi", $username) ),
    "lidarr" => array( "exists" => processExists("lidarr",$username), "enabled" => isEnabled("lidarr", $username) ),
    "lounge" => array( "exists" => processExists("lounge","lounge"), "enabled" => isEnabled("lounge", "lounge") ),
    "nzbget" => array( "exists" => processExists("nzbget",$username), "enabled" => isEnabled("nzbget", $username) ),
    "nzbhydra" => array( "exists" => processExists("nzbhydra",$username), "enabled" => isEnabled("nzbhydra", $username) ),
    "ombi" => array( "exists" => processExists("ombi",$username), "enabled" => isEnabled("ombi", $username) ),
    "plex" => array( "exists" => processExists("Plex","plex"), "enabled" => isEnabled("plexmediaserver","plex") ),
    "plexpy" => array( "exists" => processExists("Tautulli","tautulli"), "enabled" => isEnabled("tautulli","tautulli") ),
    "pyload" => array( "exists" => processExists("pyload",$username), "enabled" => isEnabled("pyload", $username) ),
    "radarr" => array( "exists" => processExists("radarr",$username), "enabled" => isEnabled("radarr", $username) ),
    "rutorrent" => array( "exists" => processExists("rtorrent",$username), "enabled" => isEnabled("rtorrent", $username) ),
    "sabnzbd" => array( "exists" => processExists("sabnzbd",$username), "enabled" => isEnabled("sabnzbd", $username) ),
    "sickchill" => array( "exists" => processExists("sickchill",$username), "enabled" => isEnabled("sickchill", $username) ),
    "medusa" => array( "exists" => processExists("medusa",$username), "enabled" => isEnabled("medusa", $username) ),
    "netdata" => array( "exists" => processExists("netdata","netdata"), "enabled" => isEnabled("netdata", "netdata") ),
    "sonarr" => array( "exists" => processExists("nzbdrone",$username), "enabled" => isEnabled("sonarr", $username) ),
    "subsonic" => array( "exists" => processExists("subsonic",$username), "enabled" => isEnabled("subsonic", "root") ),
    "syncthing" => array( "exists" => processExists("syncthing",$username), "enabled" => isEnabled("syncthing", $username) ),
    "jackett" => array( "exists" => processExists("jackett",$username), "enabled" => isEnabled("jackett", $username) ),
    "couchpotato" => array( "exists" => processExists("couchpotato",$username), "enabled" => isEnabled("couchpotato", $username) ),
    "quassel" => array( "exists" => processExists("quassel",$username), "enabled" => isEnabled("quassel", $username) ),
    "shellinabox" => array( "exists" => processExists("shellinabox","shellinabox"), "enabled" => isEnabled("shellinabox","shellinabox") ),
    "csf" => array( "exists" => processExists("lfd","root"), "enabled" => isEnabled("csf", "root") ),
    "sickgear" => array( "exists" => processExists("sickgear",$username), "enabled" => isEnabled("sickgear", $username) ),
    "znc" => array( "exists" => processExists("znc",$username), "enabled" => isEnabled("znc", $username) ),

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
