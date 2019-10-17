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
    echo $out;
}
else
{
    echo "invalid token";
}
?>
