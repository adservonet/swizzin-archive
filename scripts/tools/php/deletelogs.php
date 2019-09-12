<?php
//header('Content-Type: application/json');
if($_SERVER['REQUEST_METHOD'] == 'OPTIONS') return;

shell_exec("/srv/tools/rotatelogs.sh");
echo "logs rotated!";
?>
