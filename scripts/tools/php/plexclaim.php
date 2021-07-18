<?php
include('cors.php');
//header('Content-Type: application/json');

//$token = "test";


if (isset($_POST['token']))
{
    $token = $_POST['token'];
//    echo "token '" . $token."'\n";
}

if ($token != null)
{
    $token = preg_replace("/[^a-zA-Z0-9\-\_]+/", "", $token);
    $out = shell_exec("sudo -u plex /srv/tools/plexclaim.sh " . $token ." 2>&1");
//    echo "out '" . $out."'\n";
    if (strpos($out, 'success') !== false) {
        shell_exec("sudo systemctl restart plexmediaserver");
        echo "Plex server claimed successfully using token '".$token."'\n";
    }
    else
    {
        echo "no response for token '".$token."'\n";
    }
}
else
{
    echo "invalid token '".$token."'\n";
}
