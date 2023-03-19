---
title: Redhat/CentOS7本地源配置详解
description: Redhat/CentOS7本地源配置详解
categories:
  - Linux基础
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/yum.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/yum.jpg'
businesscard: true
comments: 'yes'
url: /archives/redhatcentos7-ben-de-yuan-pei-zhi-xiang-jie
tags:
  - Linux
abbrlink: 45b04385
date: 2022-07-13 23:44:30
updated: 2022-09-10 23:34:11
---

{% note default orange simple %} 一级标题 第一确定你的CD连接上了，段落引用如果是图形化界面只需要看看自己桌面也有没有一个光盘文件即可，不是图形化的可以在VM上分的导航栏里点击虚拟机→可移动设备→CD→连接{% endnote %}
段落引用如果以上都做了之后还提示错误的话就检查一下VM中你的虚拟机的设置里面ISO指向文件是否有指定路径。

{% note default orange simple %} 第二步在根目录下创建ISO文件夹{% endnote %}
```shell
mkdir /iso
```
{% note default orange simple %} 第三切换到yum源文件夹/etc/repos.d/并备份移动没有用的repo文件，一些没有用的reop文件因为已经启用，在设置新的源的时候会再次检测而产生错误{% endnote %}
```shell
cd /etc/yum.repos.d

mkdir /etc/yumrepo.bak
 
mv ./* ../yumrepo.bak/
```
{% note default orange simple %} 第四写下本地源配置.repo文件{% endnote %}
```shell
echo -e "[local]\nname =local\nbaseurl=file:///iso\nenabled=1                \ngpgcheck=0" > /etc/yum.repos.d/local.repo
```
{% note default orange simple %} 第五挂载到虚拟机并写入文件系统表{% endnote %}
```shell
​
mount /dev/sr0 /iso
 
echo "/dev/sr0        /iso        iso9660    defaults    0 0" >> /etc/fstab
```
{% note default orange simple %} 第六生成缓存{% endnote %}
```shell
yum clean all && yum makecache 
yum repolist all //查看yum仓库
```
以上便可以使用yum命令进行操作了。


![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
