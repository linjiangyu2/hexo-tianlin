---
title: Docker的TLS安全远程连接配置
description: Docker的TLS安全远程连接配置
categories:
  - 运维
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/tls.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/tls.jpg'
businesscard: true
comments: 'yes'
url: /archives/docker的tls安全远程连接配置
tags:
  - Linux
abbrlink: adf659df
date: 2022-07-16 15:52:19
updated: 2022-07-18 01:15:49
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
了解一下为什么做基于TLS传输协议和CA证书的远程连接
{% endnote %}
{% endwow %}

{% note default orange simple %} 在docker中，默认是不允许远程连接主机容器服务的，在普通的没有进行别的安全防护下开启的远程连接，只要隔壁老王知道你的IP地址再对你端口进行一下扫描尝试，便可以自由进出你的容器的房间，对你的容器们嘿嘿嘿，就问你怕不怕就完事了。{% endnote %}

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
所以如果有需要远程连接docker的需求，就需要基于TLS和CA的认证来保护我方容器不被嘿嘿嘿。
{% endnote %}
{% endwow %}

{% note default orange simple %} 1.生成证书和密钥{% endnote %}

{% note default orange simple %} 这里我的环境是IP:192.168.222.222，基于2375端口的远程连接，需要按自己的实际情况更改。{% endnote %}
```shell
mkdir /opt/ca && cd /opt/ca //自己随便在一个最好空的文件夹里面便可以，我默认是在/opt/ca下面进行操作

openssl genrsa -aes256 -out ca-key.prm 4096 //输入两次密码，生成CA证书私钥

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem //生成一个有效期365天的CA证书。example输入的依次是CN,Guangdong,Guangzhou...都可以随意填写。

openssl genrsa -out server-key.pem 4096 //生成服务端私钥

openssl req -subj "/CN=192.168.222.222" -sha256 -new -key server-key.pem -out server.csr //生成服务器端的证书签名请求文件

echo "subjectAltName = IP:192.168.222.222,IP:0.0.0.0" > extfile.cnf //限制可连接到服务器的IP，这里我默认是0.0.0.0全部允许，有指定服务器连接需求可更改

echo "extendedKeyUsage = serverAuth" >> extfile.cnf //设置此密钥仅使用于服务器身份验证

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \-CAcreateserial -out server-cert.pem -extfile extfile.cnf  //输入CA私钥密码，生成签名好的服务器端证书

openssl genrsa -out key.pem 4096 //生成客户端的私钥

openssl req -subj '/CN=client' -new -key key.pem -out client.csr  //生成客户端的证书签名请求文件

echo "extendedKeyUsage = clientAuth" >> extfile.cnf //拓展密钥的用途

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \-CAcreateserial -out cert.pem -extfile extfile.cnf //输入CA证书私钥密码，生成已签名认证好的客户端证书

cp ./{ca.pem,ca-key.pem,server-cert.pem,server-key.pem,cert.pem,key.pem} /etc/docker/
```
{% note default orange simple %} 2.修改docker守护进程服务文件{% endnote %}
```shell
vim /usr/lib/systemd/system/docker.service

#把ExecStart=/usr/bin/docker -H ......
修改为
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
然后重启服务
systemctl daemon-reload && systemctl restart docker

```
{% note default orange simple %} 3.在客户端主机远程连接测试{% endnote %}
```shell
scp root@192.168.222.222:/etc/docker/{ca.pem,cert.pem,key.pem} /etc/docker/    //从服务器端拉取密钥和证书

docker --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/cert.pem --tlskey=/etc/docker/key.pem -H tcp://192.168.222.222:2375 images  //尝试查看远程镜像
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
