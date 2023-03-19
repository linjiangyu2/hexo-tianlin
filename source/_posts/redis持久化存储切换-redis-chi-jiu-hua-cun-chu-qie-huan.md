---
title: redis持久化存储切换
description: redis持久化存储切换
categories:
  - 演示
  - 数据库
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/redis.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/redis.jpg'
businesscard: true
comments: 'yes'
url: /archives/redis-chi-jiu-hua-cun-chu-qie-huan
tags:
  - redis
abbrlink: 86ed3030
date: 2022-10-26 10:29:27
updated: 2022-10-26 21:38:58
---

{% note default orange simple %} 分享一个坑{% endnote %}

redis数据库的持久化存储有snapshot和aof两种

如果是使用过snapshot之后已经有了存储数据然后要开启aof的话,因为aof比snapshot机制的rdb文件的优先级高,redis默认会去加载第一次生成的aof的空文件,会导致全部数据未能被加载,然后如果这个时候你使用了save或bgsave或者触发了配置中的save机制,那就直接把当前的空数据库覆盖到rdb文件中了,那就可以准备收拾行李连夜坐船转到老挝,缅甸,柬埔寨了

解决方法:

命令行的动态更改,命令行的修改不会和重启服务一般去更新你的数据库,所以在你动态更改为aof机制后再执行重启会连同以前的数据一同备份进aof文件,当然动态更改后你还是需要把配置文件中的参数更改

```

# redis-cli 

127.0.0.1> config set appendonly yes

OK

# vim redis.conf

appendonly yes

# systemctl restart redis.service

```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
