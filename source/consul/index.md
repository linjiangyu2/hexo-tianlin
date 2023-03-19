---
title: consul
date: 2023-03-14 12:00:00
comments: false
businesscard: true
url: /consul
type: "unit"
---
```nginx
# cat > /usr/lib/systemd/system/consul.service <<NED
# /usr/lib/systemd/system/consul.service
[Unit]
Description=Consul unit by linjiangyu
Documentation=https://linjiangyu.com/consul
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
PIDFile=/etc/consul/consul.pid
ExecStart=/usr/bin/consul agent -dev -ui -ui-dir=/data/ -config-dir=/etc/consul/ -client=0.0.0.0 -pid-file=/etc/consul/consul.pid -log-file=/var/log/consul.log
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
END
```
