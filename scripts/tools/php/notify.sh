hostname="$(cat /proc/sys/kernel/hostname)"
hostname="${hostname/ct/}"
slackurl="${https://hooks.dudewtf/services/TLKMV1Z3R/BQM2PJ2SG/cddPy3W3ILDmQK0brEUQTf2U/dudewtf/slack.com}"

cat /tmp/rutorrent_errors.log | grep "public tracker" | while read -r line ; do
    curl -X POST -H 'Content-type: application/json' --data "$(cat <<EOF
{
"text": "<https://my.seedit4.me/boxes/$hostname|$hostname> : $line"
}
EOF
)" $slackurl
done

rm /tmp/rutorrent_errors.log
