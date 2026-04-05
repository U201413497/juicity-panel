#!/bin/bash

_INSTALL(){
 wget https://github.com/U201413497/juicity-panel/releases/download/juicity-server/juicity-server
 wget https://github.com/U201413497/juicity-panel/releases/download/juicity-panel/juicity-panel
 wget https://github.com/U201413497/juicity-panel/releases/download/index/index.html
 mv juicity-panel /usr/local/bin/ && mv index.html /usr/local/bin/
 chmod +x /usr/local/bin/juicity-panel && chmod +x /usr/local/bin/index.html
 mv juicity-server /usr/local/bin/ && chmod +x /usr/local/bin/juicity-server
 touch /etc/systemd/system/juicity-panel.service
 touch /etc/systemd/system/juicity-server.service
 echo "
[Unit]
Description=Juicity Management Panel
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/juicity-panel
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/juicity-panel.service
 echo "
[Unit]
Description=juicity-server Service
Documentation=https://github.com/juicity/juicity
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/juicity-server run -c /usr/local/etc/juicity/server.json --disable-timestamp
Restart=on-failure
LimitNPROC=512
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/juicity-server.service
mkdir /usr/local/etc/juicity && touch /usr/local/etc/juicity/server.json
echo "
{
    "listen": ":23182",
    "users": {
        "00000000-0000-0000-0000-000000000000": "my_password"
    },
    "certificate": "/path/to/fullchain.cer",
    "private_key": "/path/to/private.key",
    "congestion_control": "bbr",
    "log_level": "info"
}" > /usr/local/etc/juicity/server.json
systemctl enable juicity-server juicity-panel
systemctl restart juicity-panel
wget https://raw.githubusercontent.com/U201413497/script/main/backupfiles/ssl.sh && chmod +x ssl.sh && ./ssl.sh
rm ssl.sh
systemctl restart juicity-server
}

_INSTALL
