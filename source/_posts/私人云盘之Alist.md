---
title: 私人云盘之Alist
description: 私人云盘之Alist
categories:
  - 服务集群
  - 演示
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/alist.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/alist.jpg'
businesscard: true
tags:
  - storage
abbrlink: e7cd4481
date: 2022-11-23 04:54:36
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### Alist
{% endnote %}
{% endwow %}

{% folding 预览 %}
{% hideBlock 效果预览 ,orange%}
{% image https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/temp/alist.jpg %}
{% image https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/temp/al.png %}
{% endhideBlock %}
{% endfolding %}

详情看[Alist](https://alist.nn.ci/)
```shell
# curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install	// 新手使用一键脚本安装是最简单的啦
# 默认运行在5244端口，我这里是基于域名的多https服务，后面可能会写上
# 默认二进制文件存放在了/opt/alist下，这里要获取一下初始密码
# cd /opt/alist
# ./alist admin  # 会显示你的初始密码，记录起来
```
{% note default orange simple %}Alist默认支持了本地存储的挂载和多种当前比较流行的网盘挂载例如百度网盘，阿里云盘等等，但和我都没关系因为我使用的是天翼云盘{% endnote %}
{% folding cyan open, 天翼云盘挂载 %}
首先在pc网页端登陆上天翼云盘,设置好密码,进入到想要挂载的目录下，查看当前网址的最后一串数字便是文件夹ID
像我一样挂载的也是天翼云盘中alist下的目录，进入到alist目录然后查看
{% hideBlock 预览,orange %}
{% image https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/temp/1669152925609.png %}
{% endhideBlock %}

这里我遮掉的那部分就是文件夹ID了，记录下来下面要使用到
使用IP:5244或者你已经设置好了域名访问Web界面，Alist可以通过图形化后台管理在最下方点击登陆按之前获取的初始密码,登陆后可修改密码
点击Storages>Add>189Cloud
Mount Path 输入要挂载到的目录，比如我现在的alist目录中的文件全部要挂载到主目录下便填/，要挂载到主目录下的opt目录下便填/opt
Username 输入登陆的手机号
Password 输入账号密码
Rooy folder id 输入上面获得的文件夹ID
最后ADD添加启用便获得了一个私人的白嫖云盘啦,这里选择天翼云盘是因为支持在线浏览上传和下载，速度亲测平均10M/s
{% endfolding %}
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
