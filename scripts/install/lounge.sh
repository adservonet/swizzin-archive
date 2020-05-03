#!/bin/bash
# Package installer for The Lounge IRC Web Client
# Author: Liara

function _install {

#useradd lounge -m -s /bin/bash
#passwd lounge -l >>  "${SEEDIT_LOG}"  2>&1

#npm -g config set user root

sudo cat > /etc/apt/sources.list.d/nodesource.list<<'WUT'
deb https://deb.nodesource.com/node_10.x xenial main
deb-src https://deb.nodesource.com/node_10.x xenial main
WUT

curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

sudo apt update

cd /srv
wget https://github.com/thelounge/thelounge/releases/download/v4.0.0/thelounge_4.0.0-1_all.deb
sudo apt -y -q install ./thelounge_4.0.0-1_all.deb

sleep 5

systemctl stop thelounge

#npm install -g thelounge >>  "${SEEDIT_LOG}"  2>&1
#sudo -u lounge bash -c "thelounge install thelounge-theme-zenburn" >>  "${SEEDIT_LOG}"  2>&1

#mkdir -p /home/lounge/.thelounge/

cat > /etc/thelounge/config.js<<'EOF'
"use strict";

module.exports = {
        // ## Server settings

        // ### `public`
        //
        // When set to `true`, The Lounge starts in public mode. When set to `false`,
        // it starts in private mode.
        //
        // - A **public server** does not require authentication. Anyone can connect
        //   to IRC networks in this mode. All IRC connections and channel
        //   scrollbacks are lost when a user leaves the client.
        // - A **private server** requires users to log in. Their IRC connections are
        //   kept even when they are not using or logged in to the client. All joined
        //   channels and scrollbacks are available when they come back.
        //
        // This value is set to `false` by default.
        public: false,

        // ### `host`
        //
        // IP address or hostname for the web server to listen to. For example, set it
        // to `"127.0.0.1"` to accept connections from localhost only.
        //
        // For UNIX domain sockets, use `"unix:/absolute/path/to/file.sock"`.
        //
        // This value is set to `undefined` by default to listen on all interfaces.
        host: undefined,

        // ### `port`
        //
        // Set the port to listen to.
        //
        // This value is set to `9000` by default.
        port: 9000,

        // ### `bind`
        //
        // Set the local IP to bind to for outgoing connections.
        //
        // This value is set to `undefined` by default to let the operating system
        // pick its preferred one.
        bind: undefined,

        // ### `reverseProxy`
        //
        // When set to `true`, The Lounge is marked as served behind a reverse proxy
        // and will honor the `X-Forwarded-For` header.
        //
        // This value is set to `false` by default.
        reverseProxy: false,

        // ### `maxHistory`
        //
        // Defines the maximum number of history lines that will be kept in memory per
        // channel/query, in order to reduce the memory usage of the server. Setting
        // this to `-1` will keep unlimited amount.
        //
        // This value is set to `10000` by default.
        maxHistory: 10000,


        // ### `https`
        //
        // These settings are used to run The Lounge's web server using encrypted TLS.
        //
        // If you want more control over the webserver,
        // [use a reverse proxy instead](https://thelounge.chat/docs/guides/reverse-proxies).
        //
        // The available keys for the `https` object are:
        //
        // - `enable`: when set to `false`, HTTPS support is disabled
        //    and all other values are ignored.
        // - `key`: Path to the private key file.
        // - `certificate`: Path to the certificate.
        // - `ca`: Path to the CA bundle.
        //
        // The value of `enable` is set to `false` to disable HTTPS by default, in
        // which case the other two string settings are ignored.
        https: {
                enable: false,
                key: "",
                certificate: "",
                ca: "",
        },

        // ## Client settings

        // ### `theme`
        //
        // Set the default theme to serve to new users. They will be able to select a
        // different one in their client settings among those available.
        //
        // The Lounge ships with two themes (`default` and `morning`) and can be
        // extended by installing more themes. Read more about how to manage them
        // [here](https://thelounge.chat/docs/guides/theme-creation).
        //
        // This value needs to be the package name and not the display name. For
        // example, the value for Morning would be `morning`, and the value for
        // Solarized would be `thelounge-theme-solarized`.
        //
        // This value is set to `"default"` by default.
    	theme: "thelounge-theme-zenburn",
       // ### `prefetch`
        //
        // When set to `true`, The Lounge will load thumbnails and site descriptions
        // from URLs posted in channels and private messages.
        //
        // This value is set to `false` by default.
        prefetch: false,

        // ### `prefetchStorage`

        // When set to `true`, The Lounge will store and proxy prefetched images and
        // thumbnails on the filesystem rather than directly display the content at
        // the original URLs.
        //
        // This improves security and privacy by not exposing the client IP address,
        // always loading images from The Lounge and making all assets secure, which
        // resolves mixed content warnings.
        //
        // If storage is enabled, The Lounge will fetch and store images and thumbnails
        // in the `${THELOUNGE_HOME}/storage` folder.
        //
        // Images are deleted when they are no longer referenced by any message
        // (controlled by `maxHistory`), and the folder is cleaned up when The Lounge
        // restarts.
        //
        // This value is set to `false` by default.
        prefetchStorage: false,

        // ### `prefetchMaxImageSize`
        //
        // When `prefetch` is enabled, images will only be displayed if their file
        // size does not exceed this limit.
        //
        // This value is set to `2048` kilobytes by default.
        prefetchMaxImageSize: 2048,

        // ### `fileUpload`
        //
        // Allow uploading files to the server hosting The Lounge.
        //
        // Files are stored in the `${THELOUNGE_HOME}/uploads` folder, do not expire,
        // and are not removed by The Lounge. This may cause issues depending on your
        // hardware, for example in terms of disk usage.
        //
        // The available keys for the `fileUpload` object are:
        //
        // - `enable`: When set to `true`, files can be uploaded on the client with a
        //   drag-and-drop or using the upload dialog.
        // - `maxFileSize`: When file upload is enabled, users sending files above
        //   this limit will be prompted with an error message in their browser. A value of
        //   `-1` disables the file size limit and allows files of any size. **Use at
        //   your own risk.** This value is set to `10240` kilobytes by default.
        // - `baseUrl`: If you want change the URL where uploaded files are accessed,
        //   you can set this option to `"https://example.com/folder/"` and the final URL
        //   would look like `"https://example.com/folder/aabbccddeeff1234/name.png"`.
        //   If you use this option, you must have a reverse proxy configured,
        //   to correctly proxy the uploads URLs back to The Lounge.
        //   This value is set to `null` by default.
        fileUpload: {
                enable: false,
                maxFileSize: 10240,
                baseUrl: null,
        },

       // ### `transports`
        //
        // Set `socket.io` transports.
        //
        // This value is set to `["polling", "websocket"]` by default.
        transports: ["polling", "websocket"],

        // ### `leaveMessage`
        //
        // Set users' default `quit` and `part` messages if they are not providing
        // one.
        //
        // This value is set to `"The Lounge - https://thelounge.chat"` by
        // default.
        leaveMessage: "The Lounge, hosted @ https://seedit4.me",

        defaults: {
                name: "Seedit4.me",
                host: "irc.seedit4.me",
                port: 8010,
                password: "",
                tls: true,
                rejectUnauthorized: false,
                nick: "user%%%",
                username: "user",
                realname: "The Lounge User",
                join: "#seedit4me",
        },

        // ### `displayNetwork`
        //
        // When set to `false`, network fields will not be shown in the "Connect"
        // window.
        //
        // Note that even though users cannot access and set these fields, they can
        // still connect to other networks using the `/connect` command. See the
        // `lockNetwork` setting to restrict users from connecting to other networks.
        //
        // This value is set to `true` by default.
        displayNetwork: true,

        // ### `lockNetwork`
        //
        // When set to `true`, users will not be able to modify host, port and TLS
        // settings and will be limited to the configured network.
        //
        // It is often useful to use it with `displayNetwork` when setting The
        // Lounge as a public web client for a specific IRC network.
        //
        // This value is set to `false` by default.
        lockNetwork: false,

        // ## User management

        // ### `messageStorage`

        // The Lounge can log user messages, for example to access them later or to
        // reload messages on server restart.

        // Set this array with one or multiple values to enable logging:
        // - `text`: Messages per network and channel will be stored as text files.
        //   **Messages will not be reloaded on restart.**
        // - `sqlite`: Messages are stored in SQLite database files, one per user.
        //
        // Logging can be disabled globally by setting this value to an empty array
        // `[]`. Logging is also controlled per user individually in the `log` key of
        // their JSON configuration file.
        //
        // This value is set to `["sqlite", "text"]` by default.
        messageStorage: ["sqlite", "text"],

        // ### `useHexIp`
        //
        // When set to `true`, users' IP addresses will be encoded as hex.
        //
        // This is done to share the real user IP address with the server for host
        // masking purposes. This is encoded in the `username` field and only supports
        // IPv4.
        //
        // This value is set to `false` by default.
        useHexIp: false,
       identd: {
                enable: false,
                port: 113,
        },

        // ### `oidentd`
        //
        // When this setting is a string, this enables `oidentd` support using the
        // configuration file located at the given path.
        //
        // This is set to `null` by default to disable `oidentd` support.
        oidentd: null,
       ldap: {
                // - `enable`: when set to `false`, LDAP support is disabled and all other
                //   values are ignored.
                enable: false,

                // - `url`: A url of the form `ldaps://<ip>:<port>`.
                //   For plain connections, use the `ldap` scheme.
                url: "ldaps://example.com",

                // - `tlsOptions`: LDAP connection TLS options (only used if scheme is
                //   `ldaps://`). It is an object whose values are Node.js' `tls.connect()`
                //   options. It is set to `{}` by default.
                //   For example, this option can be used in order to force the use of IPv6:
                //   ```js
                //   {
                //     host: 'my::ip::v6',
                //     servername: 'example.com'
                //   }
                //   ```
                tlsOptions: {},

                // - `primaryKey`: LDAP primary key. It is set to `"uid"` by default.
                primaryKey: "uid",

                // - `baseDN`: LDAP base DN, alternative to `searchDN`. For example, set it
                //   to `"ou=accounts,dc=example,dc=com"`.
                //   When unset, the LDAP auth logic with use `searchDN` instead to locate users.

                // - `searchDN`: LDAP search DN settings. This defines the procedure by
                //   which The Lounge first looks for the user DN before authenticating them.
                //   It is ignored if `baseDN` is specified. It is an object with the
                //   following keys:
                searchDN: {
                        //   - `rootDN`: This bind DN is used to query the server for the DN of
                        //     the user. This is supposed to be a system user that has access in
                        //     read-only to the DNs of the people that are allowed to log in.
                        //     It is set to `"cn=thelounge,ou=system-users,dc=example,dc=com"` by
                        //     default.
                        rootDN: "cn=thelounge,ou=system-users,dc=example,dc=com",

                        //   - `rootPassword`: Password of The Lounge LDAP system user.
                        rootPassword: "1234",

                        //   - `ldapFilter`: it is set to `"(objectClass=person)(memberOf=ou=accounts,dc=example,dc=com)"`
                        //     by default.
                        filter: "(objectClass=person)(memberOf=ou=accounts,dc=example,dc=com)",

                        //   - `base`: LDAP search base (search only within this node). It is set
                        //     to `"dc=example,dc=com"` by default.
                        base: "dc=example,dc=com",

                        //   - `scope`: LDAP search scope. It is set to `"sub"` by default.
                        scope: "sub",
                },
        },

        // ## Debugging settings

        // The `debug` object contains several settings to enable debugging in The
        // Lounge. Use them to learn more about an issue you are noticing but be aware
        // this may produce more logging or may affect connection performance so it is
        // not recommended to use them by default.
        //
        // All values in the `debug` object are set to `false`.
        debug: {
                // ### `debug.ircFramework`
                //
                // When set to true, this enables extra debugging output provided by
                // [`irc-framework`](https://github.com/kiwiirc/irc-framework), the
                // underlying IRC library for Node.js used by The Lounge.
                ircFramework: false,

                // ### `debug.raw`
                //
                // When set to `true`, this enables logging of raw IRC messages into each
                // server window, displayed on the client.
                raw: false,
        },
};
EOF

#chown -R lounge: /home/lounge

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/lounge.sh
  service nginx reload
fi

#cat > /etc/systemd/system/lounge.service <<EOSD
#[Unit]
#Description=The Lounge IRC client
#After=znc.service
#
#[Service]
#Type=simple
#ExecStart=/usr/bin/thelounge start
#User=lounge
#Group=lounge
#Restart=on-failure
#RestartSec=5
#StartLimitInterval=60s
#StartLimitBurst=3
#
#[Install]
#WantedBy=multi-user.target
#EOSD


sudo -u thelounge /usr/bin/thelounge install thelounge-theme-zenburn >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-mininapse >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-crypto >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-ion >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-classic >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-solarized-fork-monospace >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-zenburn-monospace >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-abyss >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-amoled >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-material >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-scoutlink >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-mortified >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-solarized >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-hexified >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-light >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-onedark >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-common >>  "${SEEDIT_LOG}"  2>&1
sudo -u thelounge /usr/bin/thelounge install thelounge-theme-purplenight >>  "${SEEDIT_LOG}"  2>&1


systemctl restart thelounge >>  "${SEEDIT_LOG}"  2>&1

sleep 3
}

function _adduser {
master=$(cut -d: -f1 < /root/.master.info)
for u in "${users[@]}"; do
  if [[ $u = "$master" ]]; then
    password=$(cut -d: -f2 < /root/.master.info)
  else
    password=$(cut -d: -f2 < /root/$u.info)
  fi
  crypt=$(node /usr/lib/node_modules/thelounge/node_modules/bcryptjs/bin/bcrypt "${password}")
  cat > /etc/thelounge/users/$u.json <<EOU
{
	"password": "${crypt}",
	"log": true,
	"awayMessage": "",
	"networks": [],
	"sessions": {}
}
EOU
done
#chown -R lounge: /home/lounge
}

#if [[ -f /tmp/.install.lock ]]; then
#  log="/root/logs/install.log"
#else
#  log="/root/logs/swizzin.log"
#fi

users=($(cut -d: -f1 < /etc/htpasswd))

if [[ -n $1 ]]; then
	users=$1
	_adduser
	exit 0
fi
#. /etc/swizzin/sources/functions/npm
#npm_install
_install
_adduser


touch /install/.lounge.lock
