---
title: swap使用过度后果
description: swap使用过度的后果
categories:
  - 演示
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/swap.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/swap.jpg'
abbrlink: 6f3762be
date: 2022-12-28 21:57:08
tags:
---
###SWAP使用过多的后果

```
swap是使用磁盘空间制作的交换分区，一般在机器的物理内存不够使用时才会把部分比较不活跃数据暂时缓存在swap分区中
```

- 简单举一下例子
  - 在一个运维的交流群里面有人说他的1G内存服务器划分了8G的swap空间然后跑了**gitlab**和8个**java**服务和**cicd**(我纯路人)

```
不说Java服务的内存起伏了，就单聊聊这个gitlab，官方推荐的最低配置是2核4G才可以跑，我在虚拟机的测试中4G也是远远不够给gitlab使用，个人感觉最少给个8G才能勉强使用，毕竟启动便要2G内存（使用docker安装的可能会偏低一些但是不会低到哪去）

本来是在内存中都需要保底点说6G的内存，在真实内存只有1G的云服务器上和8G的swap空间，要怎么使用呢，其中5G的内存需求8G的swap空间要怎么顶替，众所周知内存的速度无比的快，底部是磁盘存储的swap要承担其中5G内存空间的快速频繁的读写操作会导致机器的磁盘IO繁忙，自然便会极大降低操作系统的运行速率，甚至导致宕机，这也是为什么k8s禁止使用swap的部分原因
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
