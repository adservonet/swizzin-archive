<?php
if($_SERVER['REQUEST_METHOD'] == 'OPTIONS') return;
//header('Content-Type: application/json');
shell_exec("/srv/tools/rotatelogs.sh");
echo "logs rotated!";
?>
