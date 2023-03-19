---
title: 多线程解压缩之pigz
description: 多线程解压缩之pigz
categories:
  - 运维
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/pigz.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/pigz.jpg'
businesscard: true
comments: 'yes'
url: /archives/linux
abbrlink: d932a11
date: 2023-02-24 17:23:41
tags:
---
{% note default orange simple %} 现在都是多核的高性能服务器，如果还一直单使用tar的话可就太捞了{% endnote %}
```nginx
# yum install -y pigz
```
{% radio checked,Options %}
```nginx
-b 设置压缩块大小(default 128k)
-d 解压
-k 不删除原始文件
-I 输出压缩目录
-p 最大使用线程数
-q 不输出信息
-r 递归
-S 使用sss后缀替换gz
-v 显示解压缩过程
```
{% radio checked,Example %}
```nginx
# tar --use-compress-program="pigz -k -p4" k.tar.gz ./k
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
