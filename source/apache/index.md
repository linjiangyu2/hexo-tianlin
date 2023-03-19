---
title: apache
date: 2023-01-29 16:00:00
comments: false
businesscard: true
url: /apache
type: "unit"
---
```nginx
~]# cat > /usr/lib/systemd/system/apache.service <<END
# /usr/lib/systemd/system/apache.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit apache by linjiangyu
Documentation=https://linjiangyu.com/apache
After=network.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/apache2/logs/httpd.pid
ExecStart=/usr/local/apache2/bin/httpd
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
END
```
