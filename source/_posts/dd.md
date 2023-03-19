---
title: dd
description: dd
categories:
  - Linux基础
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/dd.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/dd.jpg'
comments: true
abbrlink: a97191d
date: 2022-12-08 09:51:53
tags:
---

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### dd
{% endnote %}
{% endwow %}
```shell
# lsblk
/dev/sdb		10G
/dev/sdc		10G

# mkfs.xfs /dev/sdb 
/dev/sdc是作为要复制的"路径"设备,不需要格式化成xfs文件系统,dd命令可以将源块设备的磁盘分区上扇区的数据整个复制,连同超级区块、启动扇区、元数据和UUID都会一致复制
# mkdir /{sdb,sdc} -v
# mount /dev/sdb /sdb
# mounr /dev/sdc /sdc
# cp -a /etc/. /sdb/
# dd if=/dev/sdb of=/dev/sdc  //直接把/dev/sdb设备块复制到/dev/sdc,不指定bs
# xfs_repair -L /dev/sdc      //让日志文件归零,清理一下日志
# xfs_admin -U `uuid` /dev/sdc    //重新指定一下UUID,因为使用dd命令拷贝的时候连UUID也一并拷贝相同了
# mount /dev/sdc /sdc        //查看一下复制过来的和/dev/sdb设备上的数据是否一致
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
