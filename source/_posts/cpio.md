---
title: cpio
description: cpio
categories:
  - Linux基础
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/cpio.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/cpio.jpg'
comments: true
abbrlink: '35144386'
date: 2022-12-08 10:05:45
tags:
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### cpio
{% endnote %}
{% endwow %}

{% note default orange simple %}
优点: 可以备份任何的文件

缺点: 需要配合别的命令才能实现
{% endnote %}
#### command

```powershell
cpio -ovcB > [file|device]        //备份
cpio -ivcdu < [file|device]       //还原
cpio -ivct < [file|device]        //查看

# 备份会使用到的参数
-o   将数据复制输出到文件或设备上
-B   让默认的blocks可以增加至5120字节(默认是512字节),可以让大文件的存储速度加快

# 还原会使用到的参数
-i   将数据自文或设备复制出来
-d   自动建立目录,使用cpio所备份的内容不见得会在同一层目录中,所以要让cpio在复制的时候可以自己创建目录
-u   自动把新文件覆盖旧文件
-t   配合-i查看以cpio建立的文件或设备的你内容
-v   显示过程
-c   以portable format方式存储
```

{% note default orange simple %}
example:

备份/boot目录中的内容
{% endnote %}

```powershell
# cd /
# find boot | cpio -ocvB > /opt/boot.cpio       //打包
这里绝对不能使用绝对路径(所以使用find命令的时候在/下运行出来就会是./PATH),要不然解包的时候cpio会自动把数据解包覆盖原目录
# cd
# cpio /opt/boot.cpio < /opt/boot.cpio   //解包到当前目录
```

{% note default orange simple %}事实上cpio可以把一整个系统的数据完整的备份到光盘中{% endnote %}

```powershell
# find / | cpio -ocvB > /dev/st0     //备份
# cpio -idvc < /dev/st0              //还原
```

![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
