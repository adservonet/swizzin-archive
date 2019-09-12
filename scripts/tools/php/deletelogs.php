<?php
//header('Content-Type: application/json');
shell_exec("/srv/tools/rotatelogs.sh");
echo "logs rotated!";
?>
