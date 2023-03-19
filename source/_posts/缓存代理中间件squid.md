---
title: 缓存代理中间件squid
description: 缓存代理中间件squid
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/squid.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/squid.jpg'
businesscard: true
comments: 'yes'
url: /archives/server
abbrlink: e56cd95
date: 2023-02-25 08:48:36
tags:
---
{% note orange 'fas fa-fan' modern%}
### 编译安装
{% endnote %}
{% note default orange simple %}#### 编译参数{% endnote %}
```nginx
--preifx：指定安装路径
--sysconfdir：指定配置文件目录
--enable-arp-acl：可以在规则中设置为直接通过客户端MAC进行管理，防止客户端使用IP欺骗
--enable-linux-netfilter：使用内核过滤
--enable-linux-tproxy：支持透明模式
--enable-async-io=100：异步I/O，提升存储性能，相当于 --enable-pthreads   --enable-storeio=ufs,aufs
--enable-err-language="Simplify_Chinese"：报错时显示的语音，这里指定为Chinese
--enable-underscore：允许URL中有下划线
--enable-poll：使用Poll()模式，提升性能
--enable-gnuregex：使用GUN正则表达式
```
{% note default orange simple %}#### 编译{% endnote %}
```nginx
# useradd -r -s /sbin/nologin -M squid
# tar xf squid-release.tar.gz
# cd squid-release
# ./configure --prefix=/usr/local/squid --sysconfdir=/usr/local/squid/conf --enable-arp-acl --enable-linux-netfilter --enable-linux-tproxy --enable-async-io=100 --enable-err-language="Simplify_Chinese" --enable-underscore --enable-poll --enable-gnuregex
# make -j2 && make install
# usradd -r -s /sbin/nologin -M squid
# chown -R squid. /usr/local/squid

# vim /etc/init.d/squid.sh
export SQUID_HOME=/usr/local/squid
export PATH=${SQUID_HOME}/sbin:$PATH
# source !$
```
{% note default orange simple %}#### unit{% endnote %}
```nginx
# cat > /usr/lib/systemd/system/squid.service <<END
# /usr/lib/systemd/system/squid.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit squid by linjiangyu
Documentation=https://linjiangyu.com/squid
After=network-online.target nss-lookup.target remote-fs.target
Wants=network-online.target

[Service]
Type=simple
PIDFile=/usr/local/squid/var/run/squid.pid
ExecStart=/usr/local/squid/sbin/squid -f /usr/local/squid/conf/squid.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
User=squid
Group=squid

[Install]
WantedBy=multi-user.target
END
```
{% note default orange simple %}#### 服务启动前先修改一下配置文件让squid用户启动服务{% endnote %}
```nginx
# vim /usr/local/squid/conf/squid.conf
cache_effective_user	squid
cache_effective_group	squid
cache_dir ufs /usr/local/squid/var/cache/squid 100 16 256

# systemctl daemon-reload
# systemctl start squid.service
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
