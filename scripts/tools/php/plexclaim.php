<?php
include('cors.php');
//header('Content-Type: application/json');

$token = null;

if (isset($_POST['token']))
{
    $token = $_POST['token'];
}

if ($token != null)
{
    $out = trim(shell_exec("sudo -u plex /srv/tools/plexclaim.sh " . $token));
    var_dump($out);
}
?>
