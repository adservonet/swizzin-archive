<?php
include('cors.php');
//header('Content-Type: application/json');

$token = null;

if (isset($_GET['token']))
{
    $token = $_GET['token'];
}

if ($token != null)
{
    shell_exec("/srv/tools/plexclaim.sh " . $token);
    echo "claimed";
}
?>
