<?php
//header('Content-Type: application/json');
shell_exec("rm /srv/tools/logs/*");
shell_exec("touch /srv/tools/logs/output.log");
shell_exec("chmod 777 /srv/tools/logs/output.log");
echo "logs deleted!";
?>
