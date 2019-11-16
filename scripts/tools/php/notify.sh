hostname="$(cat /proc/sys/kernel/hostname)"
hostname="${hostname/ct/}"

cat /tmp/rutorrent_errors.log | grep "public tracker" | while read -r line ; do
    curl -X POST -H 'Content-type: application/json' --data "$(cat <<EOF
{
"text": "<https://my.seedit4.me/boxes/$hostname|$hostname> : $line"
}
EOF
)" https://hooks.slack.com/services/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
done

rm /tmp/rutorrent_errors.log
