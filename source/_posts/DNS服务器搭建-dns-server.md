---
title: DNS服务器搭建
description: DNS服务器搭建
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/dns.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/dns.jpg'
businesscard: true
comments: 'yes'
url: /archives/dns-server
tags:
  - Linux
abbrlink: '37824039'
date: 2022-09-04 20:52:58
updated: 2022-09-13 17:10:08
---

### DNS服务器搭建

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
####   1.环境准备
{% endnote %}
{% endwow %}

|    HOSTNAME     | HOSTNAME  |  AUTH   |
| :-------------: | :-------: | :-----: |
| 192.168.222.219 | node1.com | master  |
| 192.168.222.220 | node2.com |  work   |
| 192.168.222.221 | node3.com |  work   |
| 192.168.222.222 | node4.com | NFS,DNS |

{% note default orange simple %} 环境我是基于k8s搭建zookeeper的，懒得改{% endnote %}

```
[root@ nodeX]# sed -ri 's/(DNS.*)=.*/\1=192.168.222.222/g' /etc/sysconfig/ifcfg-ens33
[root@ nodeX]# systemctl restart ens33
[root@ nodeX]# yum install -y bind-utils
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
#### 2.DNS服务器的配置
{% endnote %}
{% endwow %}

#### 2.1 正向解析

``` 
[root@ node4]# yum install -y bind
[root@ node4]# vim /etc/named.conf    #修改两项
	listen-on port 53 { any; };
	allow-query		{ any; };
[root@ node4]# cat /etc/named.rfc1912.zone
zone "0.in-addr.arpa" IN {
        type master;
        file "named.empty";
        allow-update { none; };
};
```

{% note default orange simple %} 把这5行复制到最下面4遍。{% endnote %}

修改为

```
zone "node1.com" IN {
        type master;
        file "node1.com.zone";
        allow-update { none; };
};

zone "node2.com" IN {
        type master;
        file "node2.com.zone";
        allow-update { none; };
};

zone "node3.com" IN {
        type master;
        file "node3.com.zone";
        allow-update { none; };
};

zone "node4.com" IN {
        type master;
        file "node4.com.zone";
        allow-update { none; };
};
```

```
[root@ node4]# cd /var/named
[root@ node4]# cp -a named.localhost ./{node1.com.zone,node2.com.zone,node3.com.zone,node4.com.zone}
分别改为
[root@ node4]# cat node*.com.zone
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
@		A	   192.168.222.219
----------------------------------------------------------
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
www     A       192.168.222.220
----------------------------------------------------------
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
www     A       192.168.222.221
----------------------------------------------------------
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
@       A       192.168.222.222
```

```
# 可以使用named-checkconf /etc/named.conf /etc/named.conf (/etc/named.rfc1912.zone /etc/named.rfc1912.zone) 检测配置文件
# name-checkzone node(1-4).com.zone node(1-4).com.zone
# systemctl restart named  //重启服务，让配置生效
```

```
# nslookup node1.com
Server:         192.168.222.222
Address:        192.168.222.222#53

Name:   node1.com
Address: 192.168.222.219
#其余也是一样
```

#### 2.2 反向解析

```
[root@ node4]# cat /etc/named.rpc1912.zone
zone "1.0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-update { none; };
};
#还是把这5行复制4次
```

```
[root@ node4]# cat /etc/named.rpc1912.zone
zone "219.222.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.222.219.zone";
        allow-update { none; };
};
zone "220.222.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.222.220.zone";
        allow-update { none; };
};
zone "221.222.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.222.221.zone";
        allow-update { none; };
};
zone "222.222.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.222.222.zone";
        allow-update { none; };
};
```

```
[root@ node4]# cd /var/named
[root@ node4]# cp ./named.loopback ./192.168.222.219.zone
[root@ node4]# cp ./named.loopback ./192.168.222.220.zone
[root@ node4]# cp ./named.loopback ./192.168.222.221.zone
[root@ node4]# cp ./named.loopback ./192.168.222.222.zone
[root@ node4]# cat ./192.168.222.2*.zone
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
        PTR     node1.com.
19      PTR     node1.com.
---------------------------------------------------------
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
        PTR     node2.com.
20      PTR     node2.com.
---------------------------------------------------------
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
        PTR     node3.com.
21      PTR     node3.com.
---------------------------------------------------------
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
        PTR     node4.com.
22      PTR     node4.com.
```

```
[root@ node4]# systemctl restart named
[root@ nodeX]# nslookup 192.168.222.219
219.222.168.192.in-addr.arpa    name = node1.com.
```

以上。
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
