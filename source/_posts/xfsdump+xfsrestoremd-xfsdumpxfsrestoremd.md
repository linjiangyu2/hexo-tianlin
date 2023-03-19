---
title: xfsdump+xfsrestore
description: xfsdump+xfsrestore
categories:
  - 运维
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/xfs.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/xfs.jpg'
businesscard: true
comments: 'yes'
url: /archives/xfsdumpxfsrestoremd
abbrlink: b409e427
date: 2022-09-23 09:05:36
updated: 2022-09-23 09:06:02
tags:
---

### xfsdump+xfsrestore

{% note default orange simple %} example{% endnote %}

```powershell
# lsblk
sdb               8:16   0   20G  0 disk
# mkdir /{t1,t2,t3} -v
# mkfs.xfs -f /dev/sdb
# mount /dev/sdb /t1
# cp -a /etc/. /t1/
开始备份/dev/sdb设备的数据
# xfsdump -l 0 -L etc -M etc-dump -f /t2/etc.dump /t1        //完整备份/t1文件系统的数据到/t2/etc.dump
# rm -rf /t1
# xfsrestore -f /t2/etc.dump /t3     //把文件中的数据备份到/t3目录中去
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
