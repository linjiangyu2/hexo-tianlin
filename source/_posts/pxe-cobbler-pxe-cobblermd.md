---
title: pxe-cobbler
description: pxe-cobbler
categories:
  - 运维
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/pxe.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/pxe.jpg'
businesscard: true
comments: 'yes'
url: /archives/pxe-cobblermd
tags:
  - Linux
abbrlink: d2d1d8fb
date: 2022-09-07 23:12:55
updated: 2022-09-07 23:13:24
---

## Pxe-Cobbler

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
环境
{% endnote %}
{% endwow %}

|                  IP                  | HOSTNAME | ROLE |
| :----------------------------------: | :------: | :--: |
|                 dhcp                 |    t1    | dhcp |
|                 dhcp                 |    t2    |  c1  |
| 192.168.222.30,dhcp(192.168.222.201) |    t3    |  c2  |


{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
一、dhcp
{% endnote %}
{% endwow %}

{% note default orange simple %} dhcp是基于rarp，和arp相反，arp是通过对IP来识别物理网卡mac地址，而dhcp是通过识别客户端机器的物理网卡mac地址来判断给予客户端的IP地址{% endnote %}

{% note default orange simple %} 监听在67端口{% endnote %}

Server: 67/UDP

Client: 68/UDP

arp: address resolving protocol

​	IP  --> MAC

rarp: reverse arp

​	MAC --> IP

{% note default orange simple %} 工作流程:{% endnote %}

```powershell
(1) Client: dhcp discover
(2) Server: dhcp offer (IP/mask,gw...)
	lease time: 租约期限
(3) Client: dhcp request
(4) Sever: dhcp ack
续租：
	50%,75%,87.5%,
	
	单播给服务：
		dhcp request
		dhcp ack   //可以继续用
		
		dhcp request
		dhcp nak   //不可以继续使用
		
		dhcp discover
(5) Server
	dhcp:
		dhcpd: dhcp 服务
		dhcrelay: 中继,在两个网段中都起分发IP作用的dhcp服务器
```

{% note default orange simple %} 配置文件,使用dhcp服务{% endnote %}

{% note default orange simple %} dhcp的配置模板文件在/usr/share/doc/dhcp-4.2.5下面{% endnote %}

```powershell
[root@ dhcp]# yum install -y dhcp
[root@ dhcp]# cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf //模板文件拷贝
[root@ dhcp]# vim /etc/dhcp/dhcpd.conf
# 其余没有显示的我暂时注释掉了
option domain-name "linjiangyu.com";   //指定默认的DNS域名 
option domain-name-servers 119.29.29.29;  //指定默认的DNS服务器IP
default-lease-time 43200;            //默认租约时间
max-lease-time 86400;                //最大租约时间
log-facility local7;				//指定日志文件不需要修改
subnet 10.10.0.0 netmask 255.255.255.0 {   //声明要分配的网段地址
        range 10.10.0.150 10.10.0.240;       //分配地址池
        option routers  10.10.0.202;		//指定默认网关
}
```

```shell
[root@ t2]# dhclient -d    //-d是前台运行，不用-d是后台运行
# 可以看到IP地址是10.10.0.151,可能是第一个10.10.0.150被我刚开始更改为dhcp的仅主机模式的t1服务器给占了,网关是设置的10.10.0.202
```

持续更新中...
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
