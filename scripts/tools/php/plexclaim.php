<?php
include('cors.php');
//header('Content-Type: application/json');

$token = "test";

if (isset($_POST['token']))
{
    $token = $_POST['token'];
}

if ($token != null)
{
    $out = shell_exec("sudo -u plex /srv/tools/plexclaim.sh " . $token);
    echo "out: " . $out;
    if (strpos($out, 'success') !== false) {
        echo "Plex server claimed successfully using token ".$token;
    }
    else
    {
        echo "no response for token: ".$token;
    }
}
else
{
    echo "invalid token: ".$token;
}
?>
