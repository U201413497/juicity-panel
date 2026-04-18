#!/bin/bash

_INSTALL(){
 echo -n "Enter your panel-domain:"
 read domain
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
apt install nginx
cat >/etc/nginx/sites-available/default <<-EOF
server {
    listen 8443 ssl;
    listen [::]:8443 ssl;
    server_name $domain;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:8080;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }
}
EOF
systemctl enable juicity-server juicity-panel
systemctl restart juicity-panel
systemctl restart juicity-server
systemctl restart nginx
}

_INSTALL
