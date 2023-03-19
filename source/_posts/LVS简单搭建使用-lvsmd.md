---
title: LVS简单搭建使用
description: LVS搭建使用
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/lvs.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/lvs.jpg'
businesscard: true
comments: 'yes'
url: /archives/lvsmd
tags:
  - Linux
abbrlink: 115d8f31
date: 2022-09-02 09:09:06
updated: 2022-09-13 17:10:34
---

| 192.168.222.236(DIP) ,10.10.0.10(VIP) |  lvs   |  lvs   |
| :-----------------------------------: | :----: | :----: |
|         192.168.222.232(RIP)          |  rs1   | ceph1  |
|         192.168.222.233 (RIP)         |  rs2   | ceph2  |
|   192.168.222.237  ,10.10.0.20(CIP)   | client | client |

{% note default orange simple %} 了解：LVS是基于OSI模型的内核层的下四层，也是附着与netfilter的input练上{% endnote %}
# 环境

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
1.机器准备
{% endnote %}
{% endwow %}

```
# cat > /etc/hosts <<END
192.168.222.232 ceph1
192.168.222.233 ceph2
192.168.222.236 lvs
192.168.222.237 client
END
```



```
# 在每台机器上使用system.sh初始化os系统脚本。
# git clone https://github.com/linjiangyu2/K.git 
cd K 
./system.sh //依次输入DEVICE,IP,HOSTNAME,yes
最后在rs机器上
# sed -ri 's/^(GATEWAY=).*/\1192.168.222.236/g' /etc/sysconfig/network-scripts/ifcfg-ens33
# systemctl restart network
在client机器上
# sed -ri 's/^(GATEWAY=).*/\110.10.0.10/g' /etc/sysconfig/network-scripts/ifcfg-ens33
在lvs服务器上
# vim /etc/sysctl.conf
net.ipv4.ip_forward = 1 
# sysctl -p
# sysctl -a | grep 'ip_forward' //可以查看一下
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
2.时间同步
{% endnote %}
{% endwow %}

```
在lvs服务器搭建一个ntp服务器或者使用xinetd服务器（需要在各个节点上下载rdate,command:rdata lvs)
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
3.在rs真实后端服务器上搭建Web服务用于测试
{% endnote %}
{% endwow %}

```
# yum install -y nginx
[root@ rs1]# echo 'rs1' > /usr/share/nginx/html/index.html
[root@ rs2]# echo 'rs2' > /usr/share/nginx/html/index.html
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
4.开始简单的LVS配置
{% endnote %}
{% endwow %}

{% note default orange simple %} 如果rs和client的网络无法连通外网的话，需要先ifup ens33,让可连通外网的lvs网卡的网关先成为默认的网关，让节点的机器可以yum安装软件{% endnote %}

```
#可以了解一下lvs的模块以及支持的协议
# grep -i ipvs -C 10 /boot/config*
```



```
[root@ lvs]# yum install -y ipvsadm
[root@ lvs]# ipvsadm -A -t 10.10.0.10:80 -s rr
[root@ lvs]# ipvsadm -a -t 10.10.0.10:80 -r 192.168.222.232 -m
[root@ lvs]# ipvsadm -a -t 10.10.0.10:80 -r 192.168.222.233 -m
[root@ lvs]# ipvsadm -Ln //查看
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
5.测试
{% endnote %}
{% endwow %}

```
[root@ client]# for i in `seq 1 10`;do curl 10.10.0.10;done
#可以看到显示5个rs1和5个rs2,实现了一个平均分配的负载均衡
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
6.分配权重
{% endnote %}
{% endwow %}

```
[root@ lvs]# ipvsadm -E -t 10.10.0.10:80 -s wrr   //修改调度策略
[root@ lvs]# ipvsadm -e -t 10.10.0.10:80 -r 192.168.222.232 -m -w 8 //权重设置为8
[root@ lvs]# ipvsadm -e -t 10.10.0.10:80 -r 192.168,222,233 -m -w 2 //权重设置为2
[root@ lvs]# ipvsadm -Z   //清空计数
[root@ lvs]# ipvsadm -Ln --rate  //查看

[root@ client]# for i in `seq 1 10`;do curl 10.10.0.10;done  //测试
#可以看到10个请求中，8个发给了rs1，2个发给了rs2
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
7.sh(类似于nginx负载均衡upstream里面的hash)
{% endnote %}
{% endwow %}

```
# ipvsadm -E -t 10.10.0.10:80 -s sh
# ipvsadm -Z
# ipvsadm -Ln
[root@ client]# for i in `seq 1 3`;do curl 10.10.0.10;done
rs1
rs1
rs1
or
rs2
rs2
rs2
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
8.wlc(DO/weight) //按RS服务器的负荷，通过调度算法分配
{% endnote %}
{% endwow %}

```
# 懒得写了，自己悟吧。
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
