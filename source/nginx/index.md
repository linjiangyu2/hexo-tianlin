---
title: nginx
date: 2022-11-06 00:00:00
comments: false
businesscard: true
url: /nginx
type: "unit"
---
```nginx
~]# cat > /usr/lib/systemd/system/nginx.service <<END
# /usr/lib/systemd/system/nginx.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit nginx by linjiangyu
Documentation=https://linjiangyu.com/nginx
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
END
```

```nginx
# tee /usr/lib/systemd/system/nginx.service <<END
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=Unit nginx by linjiangyu
Documentation=https://linjiangyu.com/nginx
After=network.target nss-lookup.target network-online.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
END
```
