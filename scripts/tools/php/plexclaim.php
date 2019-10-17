<?php
include('cors.php');
//header('Content-Type: application/json');

if (isset($_POST['token']))
{
    $token = $_POST['token'];
//    echo "token '" . $token."'\n";
}

if ($token != null)
{
    $out = shell_exec("sudo sh /srv/tools/plexclaim.sh " . $token ." 2>&1");
    echo "out '" . $out."'\n";
    if (strpos($out, 'success') !== false) {
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
