<?php
include('cors.php');
//header('Content-Type: application/json');

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
    //$proc_exists = false;

    $service = false;
    $enabled = false;
    $active = false;

//    exec("ps axo user:20,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,comm,cmd| grep -iE $process | grep -v grep", $pids);
//    if (count($pids) > 0) $proc_exists = true;

    if(file_exists("/etc/systemd/system/".$process.$username.".service")) $serv_exists = true;
    else if(file_exists("/lib/systemd/system/".$process.$username.".service")) $serv_exists = true;
    else if(file_exists("/etc/systemd/system/multi-user.target.wants/".$process.$username.".service")) $serv_exists = true;
    else if(file_exists("/sys/fs/cgroup/systemd/system.slice/".$process.$username.".service")) $serv_exists = true;

    if ($serv_exists)
    {
        try {$service = $systemCtl->getService($process.$username);}
        catch (Exception $e) {$service = false; echo $e;}

        if ($service)
        {
//            try {$enabled = $service->isEnabled();}
//            catch (Exception $e) {$enabled = false;}
//
//            if ($enabled)
//            {
                try {$active = $service->isActive();}
                catch (Exception $e) {$active = false;}
//            }
        }
        return array( "exists" => +$serv_exists, "enabled" => +$enabled, "active" => +$active );
    }
    return "";
}

$username = "seedit4me";

$apps = array(
    array("name" => "openvpn2",       "service" => "openvpn",           "user" => "server"),
    array("name" => "proftpd",        "service" => "proftpd",           "user" => ""),
    array("name" => "bazarr",         "service" => "bazarr",            "user" => ""),
    array("name" => "btsync",         "service" => "resilio-sync",      "user" => ""),
    array("name" => "deluged",        "service" => "deluged",           "user" => $username),
    array("name" => "deluge",         "service" => "deluge-web",        "user" => $username),
    array("name" => "transmission",   "service" => "transmission-daemon","user" => ""),
    array("name" => "emby",           "service" => "emby-server",       "user" => ""),
    array("name" => "filebrowser",    "service" => "filebrowser",       "user" => ""),
    array("name" => "flood",          "service" => "flood",             "user" => $username),
    array("name" => "headphones",     "service" => "headphones",        "user" => ""),
    array("name" => "autodl",         "service" => "irssi",             "user" => $username),
    array("name" => "lazylibrarian",  "service" => "lazylibrarian",     "user" => $username),
    array("name" => "lidarr",         "service" => "lidarr",            "user" => ""),
    array("name" => "lounge",         "service" => "lounge",            "user" => ""),
    array("name" => "nzbget",         "service" => "nzbget",            "user" => $username),
    array("name" => "nzbhydra",       "service" => "nzbhydra",          "user" => $username),
    array("name" => "ombi",           "service" => "ombi",              "user" => ""),
    array("name" => "plex",           "service" => "plexmediaserver",   "user" => ""),
    array("name" => "plexpy",         "service" => "plexpy",            "user" => ""),
    array("name" => "tautulli",       "service" => "tautulli",          "user" => ""),
    array("name" => "pyload",         "service" => "pyload",            "user" => ""),
    array("name" => "radarr",         "service" => "radarr",            "user" => ""),
    array("name" => "rclone",         "service" => "rclone",            "user" => $username),
    array("name" => "rutorrent",      "service" => "rtorrent",          "user" => $username),
    array("name" => "qbittorrent",    "service" => "qbittorrent",       "user" => ""),
    array("name" => "sabnzbd",        "service" => "sabnzbd",           "user" => $username),
    array("name" => "sickchill",      "service" => "sickchill",         "user" => $username),
    array("name" => "medusa",         "service" => "medusa",            "user" => $username),
    array("name" => "netdata",        "service" => "netdata",           "user" => ""),
    array("name" => "sonarr",         "service" => "sonarr",            "user" => $username),
    array("name" => "subsonic",       "service" => "subsonic",          "user" => ""),
    array("name" => "syncthing",      "service" => "syncthing",         "user" => $username),
    array("name" => "jackett",        "service" => "jackett",           "user" => $username),
    array("name" => "couchpotato",    "service" => "couchpotato",       "user" => $username),
    array("name" => "quassel",        "service" => "quasselcore",       "user" => ""),
    array("name" => "shellinabox",    "service" => "shellinabox",       "user" => ""),
    array("name" => "csf",            "service" => "csf",               "user" => ""),
    array("name" => "sickgear",       "service" => "sickgear",          "user" => $username),
    array("name" => "znc",            "service" => "znc",               "user" => "")
);


if (isset($_GET['servicedisable']))
{
    $process = $_GET['servicedisable'];
    foreach($apps as $app)
    {
        if ($process == $app["name"])
        {
            $username = "";
            if ($app["user"] != "") $username = "@".$app["user"];
            shell_exec("sudo systemctl stop ".$app["service"].$username);
            //shell_exec("sudo systemctl disable ".$app["service"].$username);
        }
    }
}
else if (isset($_GET['servicestart']))
{
    $process = $_GET['servicestart'];
    foreach($apps as $app)
    {
        if ($process == $app["name"])
        {
            $username = "";
            if ($app["user"] != "") $username = "@".$app["user"];
            //shell_exec("sudo systemctl enable ".$app["service"].$username);
            shell_exec("sudo systemctl restart ".$app["service"].$username);
        }
    }
}
else
{
    $appstatus = array();
    foreach($apps as $app)
    {
        $username = "";
        if ($app["user"] != "") $username = "@".$app["user"];
        $appstatus[$app["name"]] = array (isEnabled($app["service"],$username));
    }
    echo json_encode($appstatus);
}
?>
