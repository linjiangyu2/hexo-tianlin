---
title: vsftpd的简单搭建
description: vsftpd的简单搭建
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/vsftpd.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/vsftpd.jpg'
businesscard: true
comments: 'yes'
url: /archives/vsftpd-server
tags:
  - Linux
abbrlink: d38cd35f
date: 2022-09-05 08:58:57
updated: 2022-09-29 09:16:16
---

###  vsftpd服务器搭建

#### 1.环境

|       IP        | HOTSNAME |  RULE  |
| :-------------: | :------: | :----: |
| 192.168.222.100 |  vsftpd  | server |
| 192.168.222.101 |  client  | client |

```
# cat > /etc/hosts<<END
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.222.100 vsftpd
192.168.222.101 client
END
```



#### 2.配置

```
[root@ vsftpd]# yum install -y vsftpd
[root@ vsftpd]# useradd test
[root@ vsftpd]# echo 123 | passwd --stdin test
[root@ vsftpd]# mkdir -p /data/test
[root@ vsftpd]# cp -a /etc/passwd /data/test/
[root@ vsftpd]# chown -R test. /data
[root@ vsftpd]# cat /etc/vsftpd/vsftpd.conf
local_enable=YES
#写总开关
write_enable=YES
#file:644 dircovrty:755（mask）
local_umask=022
#指定用户访问目录
local_root=/data/test
#限定用户只能在/data/lt目录下活动
chroot_local_user=YES
#给限定用户写入的权限
allow_writeable_chroot=YES
#启用消息功能
dirmessage_enable=YES
#启用xferlog日志
xferlog_enable=YES
#支持主动模式(默认被动)
connect_from_port_20=YES
#xferlog日志格式
xferlog_std_format=YES
#ftp服务独立模式下的监听
listen=YES
#是否支持IPv6(不支持的话一定要注释或者NO)
#listen_ipv6=YES
#指定认证文件
pam_service_name=vsftpd
#启用用户列表
userlist_enable=YES
#支持tcp_wrappers功能(传输限速)
tcp_wrappers=YES
```

{% note default orange simple %} 以上是我配置完了的{% endnote %}

```
[root@ clinet]# yum install -y ftp
[root@client ~]# ftp vsftpd
Connected to 192.168.222.100 (192.168.222.100).
220 (vsFTPd 3.0.2)
Name (192.168.222.100:root): test
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ? //？或者help可以显示命令帮助
ftp> get passwd   //获取当前目录的passwd文件到本地
```

持续更新...
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
