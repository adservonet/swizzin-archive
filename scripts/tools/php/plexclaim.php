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
    $out = trim(shell_exec("sudo -u plex /srv/tools/plexclaim.sh " . $token));
    if (strpos($out, 'success') !== false) {
        echo "Plex server claimed successfully using token ".$token;
    }
}
else
{
    echo "invalid token: ".$token;
}
?>
