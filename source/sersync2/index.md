---
title: sersync2
date: 2023-01-29 16:00:00
comments: false
businesscard: true
url: /sersync2
type: "unit"
---
sersync [args] [conf.file]
args:
  -r 在监控目录之前先把目录文件推送一遍
  -d 以后台daemon的方式运行
  -o 指定[conf.file]
> 使用unit的前提是先手动执行一遍同步操作sersync2 -ro confxml.xml，后面unit不可能一直带着-r参数(感觉也不是不可以看实际情况，因为加了-r的话每次重启服务都是一次全量备份)
```nginx
# cat > /usr/lib/systemd/system/sersync.service <<END
# /usr/lib/systemd/system/sersync.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=sersync unit by linjiangyu
Documentation=https://linjiangyu.com/sersync
After=network-online.target remote-fs.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/sersync/sersync2 -o /usr/local/sersync/confxml.xml
ExecReload=/bin/kill -s HUP 
ExecStop=/bin/kill -s TERM 

[Install]
WantedBy=multi-user.target
END
```
