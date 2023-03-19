---
title: sersync2实时监控同步文件
description: sersync2实时监控同步文件
categories:
  - 服务集群
  - 演示
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/sesync.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/sesync.jpg'
businesscard: true
comments: 'yes'
url: /archives/sesync
tags:
  - Linux
abbrlink: f2af38d6
date: 2022-11-12 23:20:01
---

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
sesync的实时同步
{% endnote %}
{% endwow %}

{% link sesync2,https://alist.linjiangyu.com/d/Linux/sersync2.5.4_64bit_binary_stable_final.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}



{% note default orange simple %} 也要结合rsync和Inotify一起使用{% endnote %}

|       IP        | HOSTNAME |
| :-------------: | :------: |
| 192.168.222.160 |  master  |
| 192.168.222.161 |  backup  |

{% note default orange simple %} backup的rsyncd的配置{% endnote %}

```powershell
# yum install -y rsync
# vim /etc/rsyncd.conf
uid = root
gid = root
#use chroot = yes
max connections = 0
pid file = /var/run/rsyncd.pid
exclude = lost+found/
#transfer logging = yes
#timeout = 900
#ignore nonreadable = yes
#dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
reverse lookup = no

[backup]
       path = /opt      # 共享的目录
       comment = ftp export area 
       read only = no
       auth users = lt         # 登陆的用户名
       secrets file = /etc/rsync.pas   # 认证文件
 # 创建认证文件
 # echo 'lt:123' > /etc/rsync.pas
 # systemctl restart rsyncd
```

{% note default orange simple %} master的配置{% endnote %}

```powershell
[root@master~]# yum install -y rsync inotify-tools
[root@master~]# rsync rsync://192.168.222.161  //显示192.168.222.161服务器共享的rsyncd的名字
[root@master~]# rsync rsync://lt@192.168.222.161/backup   //查看目录,也可以上传目录,但是也可以上传发送文件,但是是需要交互式输入密码认证的
[root@master~]# echo 123 > /etc/rsync.pas         //认证文件
[root@master~]# rsync --password-file=/etc/rsync.pas lt@192.168.222.161::backup
或者
[root@master~]# rsync --password-file=/etc/rsync.pas rsync://lt@192.168.222.161/backup
[root@master~]# tar xf sersync* 
[root@master~]# mv sersync* /usr/local/sersync
[root@master~]# vim /etc/profile
export SERSYNC_HOME=/usr/local/sersync
export PATH=${SERSYNC_HOME}:$PATH
[root@master~]# source /etc/profile
[root@master~]# cd /usr/local/sersync
[root@master~]# vim confxml.xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">   <!--<是否开启过滤功能，为true的话设置以下的类型文件不同步 >-->
        <exclude expression="(.*)\.svn"></exclude>
        <exclude expression="(.*)\.gz"></exclude>
        <exclude expression="^info/*"></exclude>
        <exclude expression="^static/*"></exclude>
    </filter>
    <inotify>
        <delete start="true"/>
        <createFolder start="true"/>
        <createFile start="true"/>      <!--<修改>-->
        <closeWrite start="true"/>
        <moveFrom start="true"/>
        <moveTo start="true"/>
        <attrib start="true"/>     <!--<修改>-->
        <modify start="false"/>
    </inotify>

    <sersync>
        <localpath watch="/opt/">               <!--<监控的目录>-->
            <remote ip="192.168.222.161" name="backup"/>   <!--<修改目标IP地址,backup是共享出来的服务名称>-->
            <!--<remote ip="192.168.8.39" name="tongbu"/>-->
            <!--<remote ip="192.168.8.40" name="tongbu"/>-->
        </localpath>
        <rsync>
            <commonParams params="-artuz"/>             <!--<rsync传输时间携带的参数>-->
            <!--<修改,开启才能修改,还有登陆的lt用户和认证的文件>-->
            <auth start="true" users="lt" passwordfile="/etc/rsync.pas"/>
            <userDefinedPort start="false" port="874"/><!-- port=874 -->
            <timeout start="false" time="100"/><!-- timeout=100 -->
            <ssh start="false"/>
        </rsync>
        <failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
        <crontab start="false" schedule="600"><!--600mins-->
            <crontabfilter start="false">
                <exclude expression="*.php"></exclude>
                <exclude expression="info/*"></exclude>
            </crontabfilter>
        </crontab>
        <plugin start="false" name="command"/>
    </sersync>
                                <!--<以下不需要修改 >-->
    <plugin name="command">
        <param prefix="/bin/sh" suffix="" ignoreError="true"/>  <!--prefix /opt/tongbu/mmm.sh suffix-->
        <filter start="false">
            <include expression="(.*)\.php"/>
            <include expression="(.*)\.sh"/>
        </filter>
    </plugin>

    <plugin name="socket">
        <localpath watch="/opt/tongbu">
            <deshost ip="192.168.138.20" port="8009"/>
        </localpath>
    </plugin>
    <plugin name="refreshCDN">
        <localpath watch="/data0/htdocs/cms.xoyo.com/site/">
            <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
            <sendurl base="http://pic.xoyo.com/cms"/>
            <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
        </localpath>
    </plugin>
</head>
```

{% note default orange simple %} 了解一下sersync2命令的参数{% endnote %}

```powershell
参数-d:启用守护进程模式
参数-r:在监控前，将监控目录与远程主机用rsync命令推送一遍
参数-n: 指定开启守护线程的数量，默认为10个
参数-o:指定配置文件，默认使用confxml.xml文件
参数-m:单独启用其他模块，使用 -m refreshCDN 开启刷新CDN模块
参数-m:单独启用其他模块，使用 -m socket 开启socket模块
参数-m:单独启用其他模块，使用 -m http 开启http模块
不加-m参数，则默认执行同步程序
```

```powershell
所以使用
# sersync2 -dro /usr/local/sesync/confxml.xml      //第一次使用先同步一次,第二次使用就可以去除-r参数
```

{% note default orange simple %} ssh的连接{% endnote %}
{% note default orange simple %} rsync的服务连接貌似是没有数据加密的，为了安全起见需要使用ssh{% endnote %}

```powershell
# vim /usr/local/sesync/confxml.xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">   <!--<是否开启过滤功能，为true的话设置以下的类型文件不同步 >-->
        <exclude expression="(.*)\.svn"></exclude>
        <exclude expression="(.*)\.gz"></exclude>
        <exclude expression="^info/*"></exclude>
        <exclude expression="^static/*"></exclude>
    </filter>
    <inotify>
        <delete start="true"/>
        <createFolder start="true"/>
        <createFile start="false"/>
        <closeWrite start="true"/>
        <moveFrom start="true"/>
        <moveTo start="true"/>
        <attrib start="true"/>     <!--<修改>-->
        <modify start="false"/>
    </inotify>

    <sersync>
        <localpath watch="/opt/">
            <remote ip="192.168.222.161" name="/opt"/>   <!--<修改为要传输到backup机器的目标地址>-->
            <!--<remote ip="192.168.8.39" name="tongbu"/>-->
            <!--<remote ip="192.168.8.40" name="tongbu"/>-->
        </localpath>
        <rsync>
            <commonParams params="-artuz"/>
            <!--<修改,关闭>-->
            <auth start="false" users="lt" passwordfile="/etc/rsync.pas"/>
            <userDefinedPort start="false" port="874"/><!-- port=874 -->
            <timeout start="false" time="100"/><!-- timeout=100 -->
            <ssh start="true"/>          <!--<修改,开启ssh连接>-->
        </rsync>
        <failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
        <crontab start="false" schedule="600"><!--600mins-->
            <crontabfilter start="false">
                <exclude expression="*.php"></exclude>
                <exclude expression="info/*"></exclude>
            </crontabfilter>
        </crontab>
        <plugin start="false" name="command"/>
    </sersync>
                                <!--<以下不需要修改 >-->
    <plugin name="command">
        <param prefix="/bin/sh" suffix="" ignoreError="true"/>  <!--prefix /opt/tongbu/mmm.sh suffix-->
        <filter start="false">
            <include expression="(.*)\.php"/>
            <include expression="(.*)\.sh"/>
        </filter>
    </plugin>

    <plugin name="socket">
        <localpath watch="/opt/tongbu">
            <deshost ip="192.168.138.20" port="8009"/>
        </localpath>
    </plugin>
    <plugin name="refreshCDN">
        <localpath watch="/data0/htdocs/cms.xoyo.com/site/">
            <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
            <sendurl base="http://pic.xoyo.com/cms"/>
            <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
        </localpath>
    </plugin>
</head>
```

{% note default orange simple %} 需要同步多个目录就需要编写多个confxml.xml然后不同进程地执行{% endnote %}
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
