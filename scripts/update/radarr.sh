#!/bin/bash

export log="/srv/tools/logs/output.log"

master=$(cut -d: -f1 < /root/.master.info)
password=$(cut -d: -f2 < /root/.master.info)

if [[ -f /install/.radarr.lock ]]; then

  apt install jq
	#Move v3mono installs to v3.net
	if grep -q "ExecStart=/usr/bin/mono" /etc/systemd/system/radarr.service; then
		echo "Moving Radarr from mono to .Net"
		sleep 10 # TODO change this to something that would check that the Rqadarr API is query-able, as without this you will see nginx 502s
		echo "Found radarr service pointing to mono"
		#shellcheck source=sources/functions/utils
		#. /etc/swizzin/sources/functions/utils
		[[ -z $radarrOwner ]] && radarrOwner=${master}
		apikey=$(grep -oPm1 "(?<=<ApiKey>)[^<]+" /home/"${radarrOwner}"/.config/Radarr/config.xml)
		echo "Apikey = $apikey"
		# basicauth=$(echo "${radarrOwner}:$(_get_user_password ${radarrOwner})" | base64)
		if [[ -f /install/.nginx.lock ]]; then
			ret=$(curl -sS -L --insecure --user "${radarrOwner}":"${password}" "http://127.0.0.1/radarr/api/v3/system/status?apiKey=${apikey}")
		else
			ret=$(curl -sS -L --insecure "http://127.0.0.1:7878/api/v3/system/status?apiKey=${apikey}")
		fi
		echo "Content of ret =\n ${ret}"
		if echo "$ret " | jq . >> "$log" 2>&1; then
			isnetcore=$(jq '.isNetCore' <<< "$ret")
		else
			echo "jq decided ret wasn't valid"
		fi

		##TODO find a different way to check this seeing as we need to query Radarr API, would ben nicer to do from FS
		if [[ $isnetcore = "false" ]]; then # This case confirms we are running on v3 without .net core, i.e. the case we want to update

			echo "Downloading source files"
			if ! curl "https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" -L -o /tmp/Radarr.tar.gz >> "$log" 2>&1; then
				echo "Download failed, exiting"
				exit 1
			fi
			echo "Source downloaded"

			echo "Extracting archive"
			systemctl stop radarr -q
			rm /opt/Radarr/Radarr.exe
			tar -xvf /tmp/Radarr.tar.gz -C /opt >> "$log" 2>&1
			chown -R "$radarrOwner":"$radarrOwner" /opt/Radarr
			echo "Archive extracted"

			# Watch out!
			# If this sed runs, the updater will not trigger anymore. keep this at the bottom.
			sed -i "s|ExecStart=/usr/bin/mono /opt/Radarr/Radarr.exe|ExecStart=/opt/Radarr/Radarr|g" /etc/systemd/system/radarr.service
			#

			systemctl daemon-reload
			systemctl start radarr -q
			echo "Radarr upgraded to .Net"

		else #	This case triggers if the v3 API did not return correctly, which would indicate a switched off v3 or a v02
			echo "Could not reach v3 API.
Please upgrade your radarr to v3 and ensure it is running to continue.
The next time you will run 'box update', the instance will be migrated to .Net core"
			echo "application/radarr#migrating-to-v3-on-net-core"
		fi
	fi

	#If nginx config is missing the attributes to have radarrv3 refresh UI right, then trigger the nginx script and reload
	if [[ -f /install/.nginx.lock ]]; then
		if ! grep "proxy_http_version 1.1" /etc/nginx/apps/radarr.conf -q; then
			echo "Upgrading nginx config for Radarr"
			bash /etc/swizzin/scripts/nginx/radarr.sh
			systemctl reload nginx -q
			echo "Nginx conf for Radarr upgraded"
		fi
	fi
fi
