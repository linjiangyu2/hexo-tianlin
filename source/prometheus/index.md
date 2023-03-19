---
title: prometheus
date: 2022-11-06 00:00:00
comments: false
businesscard: true
url: /prometheus
type: "unit"
---
```nginx
~]# cat > /usr/lib/systemd/system/prometheus.service <<END
# /usr/lib/systemd/system/prometheus.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Prometheus unit demo
Documentation=https://linjiangyu.com/prometheus
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
User=prometheus
Group=prometheus
KillSignal=SIGQUIT
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
END
```
- node-exporter
```nginx
# cat > node-exporter.service <<END
# /usr/lib/systemd/system/node-exporter.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit node-exporter by linjiangyu
Documentation=https://linjiangyu.com/prometheus
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/node-exporter/node_exporter 
ExecReload=/bin/kill -s HUP
ExecStop=/bin/kill -s TERM
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
END
```
