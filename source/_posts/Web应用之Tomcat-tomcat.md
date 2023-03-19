---
title: Web应用之Tomcat
description: Web应用之Tomcat
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/tomcat.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/tomcat.jpg'
businesscard: true
comments: true
url: /archives/tomcat
tags:
  - Linux
abbrlink: d5d9f79c
date: 2022-11-03 15:50:40
updated: 2022-11-03 15:53:03
---

## Tomcat

### 二进制安装

{% note default orange simple %} 安装jdk{% endnote %}

{% folding cyan open, 这里使用的二进制包 %}

{% link jdk-8u212-linux-x64.tar.gz,https://alist.linjiangyu.com/d/Linux/jdk-8u212-linux-x64.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}
```powershell
# tar xf jdk-8u212-linux-x64.tar.gz
# mv jdk-8u212-linux /usr/local/jdk
```

{% folding cyan open, 这里使用的二进制包 %}

{% link apache-tomcat-9.0.65-src.tar.gz,https://alist.linjiangyu.com/d/Linux/apache-tomcat-9.0.65-src.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}
{% link tomcat-native-1.2.23-src.tar.gz,https://alist.linjiangyu.com/d/Linux/tomcat-native-1.2.23-src.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}

```powershell
# tar xf apache-tomcat-9.0.65-src.tar.gz
# mv apache-tomcat-9.0.65-src /usr/local/tomcat
```

```powershell
# yum install apr apr-devel apr-utils openssl-devel
# tar xf tomcat-native-1.2.23-src.tar.gz 
# cd tomcat-native-1.2.23-src/native/
# ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=/usr/local/jdk --prefix=/usr/local/tomcat
# make && make install
```

{% note default orange simple %} 将jdk和tomcat写入环境变量{% endnote %}

```powershell
# vim /etc/profile
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=/usr/local/jdk/jre
export TOMCAT_HOME=/usr/local/tomcat
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH
```

{% note default orange simple %} 可以自己写一个小脚本{% endnote %}

```powershell
<<END
author: linjiangyu
cc: http://creativecommons.org/licenses/by-nc-sa/4.0/
END
# vim /etc/init.d/tomcat
#!/bin/bash
#chkconfig: 2345 85 15
#description: By K <linjiangyu0702@qq.com>
case $1 in
start)
    /usr/local/tomcat/bin/startup.sh 
    ;;
stop)
    /usr/local/tomcat/bin/shutdown.sh
    ;;
status)    
    /usr/local/tomcat/bin/configtest.sh
    ;;
*)
    echo -e "\033[31mUsage: $(basename $0) (start|stop|status)\033[0m"
    ;;
esac

<!--这里要吐槽一下java的程序运行的是真的慢，服务刚启动的话8005的套接字端口不会那么快就启用，而关闭服务的时候是要使用到8005端口shutdown的，所以应该把restart服务加上一段时间-->

# chmod +x /etc/init.d/tomcat
# vim /usr/local/tomcat/bin/catalina.sh	# 把环境变量写入相应需要的文件中(tomcat的变量这里没有引用系统环境变量,所以要自己再写上)
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=/usr/local/jdk/jre
# chkconfig --add tomcat
# chkconfig tomcat on
# service tomcat start
```

#### 1.优点和功能

{% note default orange simple %} 优点和功能{% endnote %}

```powershell
Tomcat运行时占用的系统资源小，扩展性好，支持负载均衡与邮件服务等开发应用系统常用的功能；

Tomcat是一个开源的web服务器 ;

Tomcat是一个小型的轻量级应用服务器，在中小型系统和并发访问用户不是很多的场合下被普遍使用，是开发和调试JSP程序的首选。

对于一个初学者来说，可以这样认为，当在一台机器上配置好Apache服务器，可利用它响应对HTML页面的访问请求。实际上Tomcat部分是Apache服务器的扩展，所以当你运行tomcat时，它实际上作为一个Apache独立的进程单独运行的。 当配置正确时，Apache为HTML页面服务，而Tomcat实际上运行JSP页面和Servlet。另外，Tomcat和IIS、Apache等Web服务器一样，具有处理HTML页面的功能，另外它还是一个Servlet和JSP容器，独立的Servlet容器是Tomcat的默认模式。

不过，Tomcat处理静态HTML的能力不如Apache服务器。
```

#### 2.组件

```powershell
Server: 控制tomcat的启动和关闭,tomcat的生命周期由Server控制

Engine: 负责处理所有的请求,处理后将结果返回给Service,而connector是作为service与engine的作为中间交流者；一个engine下可以配置一个默认主机，每个虚拟主机都有一个域名

Connector 主要负责对外交流

Host：代表一个虚拟主机，每个虚拟主机和某个网络域名（Domain Name）相匹配。 每个虚拟主机下都可以部署一个或多个web应用，每个web应用对应于一个context，有一个context path。 当Host获得一个请求时，将把该请求匹配到某个Context上

Wrapper： 代表一个 Servlet，它负责管理一个 Servlet，包括的 Servlet 的装载、初始化、执行以及资源回收。Wrapper 是最底层的容器，它没有子容器
```

#### 3.配置

{% note default orange simple %} 用户认证登陆{% endnote %}

```powershell
# vim /etc/tomcat/tomcat-user.xml
<user username="tomcat" password="abcd0702" roles="manager-gui"/>  设置登陆用户和密码,role设置为可以查看管理web界面的权限manager-gui

- manager-gui -允许访问HTML GUI和状态页面

- manager-script -允许访问HTTP API和状态页面

- manager-jmx -允许访问JMX代理和状态页

- manager-status -只允许访问状态页
```

{% note default orange simple %} tomcat默认静态网页的存放位置在/usr/share/tomcat/webapps/ROOT/下{% endnote %}

...还在编写中
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
