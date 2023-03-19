---
title: Redhat/CentOS用yum命令下载依赖和安装包到本地，自建yum源仓库
description: Redhat/CentOS用yum命令下载依赖和安装包到本地，自建yum源仓库
categories:
  - Linux基础
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/yumdownload.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/yumdownload.jpg'
businesscard: true
comments: 'yes'
url: >-
  /archives/redhatcentos-yong-yum-ming-ling-xia-zai-yi-lai-he-an-zhuang-bao-dao-ben-de--zi-jian-yum-yuan-cang-ku
tags:
  - Linux
abbrlink: 1b152b3a
date: 2022-07-14 01:34:22
updated: 2022-07-18 01:54:04
---

###  拓展：同步网络源到本地目录，以方便内网快速传输，更利于制作本地yum源。
```shell
reposync --repoid=xxxx        #xxxx为镜像仓库名称
```
{% note default orange simple %} 命令使用后会在当前目录生成一个一样xxxx 的文件夹，里面放的便是你选择仓库的rpm包，一样xxxx目录下会有一个repodata目录可以为写入repo文件做指定的。写入repo文件便于以下自制本地源一样。{% endnote %}
### 自建yum源就是使用自己本地的rpm包来作为yum的源仓库。扩展 使用yum命令下载安装包以及依赖文件到本地。
{% note default orange simple %} 1.可以在yum命令安装的同时不清除安装包{% endnote %}
```shell
vim /etc/yum.conf
 
cachedir=/var/cache/yum/$basearch/$releasever    //自定义安装包及依赖下载目录
keepcache=0       //1为启用，0不启用，把这里改为1
```
{% note default orange simple %} 2.直接用命令下载包和依赖（不包括安装）{% endnote %}
```shell
# yum install -y yum-utils
# yumdownloader --resolve --destdir=<PATH> <packages>
```
{% note default orange simple %} 3.创建yum自建仓库{% endnote %}
```shell
yum install -y createrepo    
 
createrepo 本地存放安装包的文件夹
 
vim /etc/yum.repos.d/dly.repo
 
[dly]
name=dly
baseurl=file:///本地存放安装包文件夹路径
enabled=1
gpgcheck=0
```
然后执行一下清理和缓存命令就可以了
```shell
yum clean all && yum makecache
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
