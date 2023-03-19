---
title: Web状态响应码
description: Web状态响应码
categories:
  - 演示
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/status.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/status.jpg'
businesscard: true
comments: 'yes'
url: /archives/web-zhuang-tai-xiang-ying-ma
abbrlink: bd934ac8
date: 2022-07-29 11:20:48
updated: 2022-07-29 18:15:13
tags:
---

{% note default orange simple %} 403 Forbidden.服务器已经理解请求,但是拒绝执行它(大部分原因是因为文件的属性和权限问题){% endnote %}

{% note default orange simple %} 404 Not Found.请求失败,请求所希望得到的资源未在服务器上发现.{% endnote %}
404这个状态码被广泛应用于当服务器不想揭示为何请求被拒绝,或者没有其他适合的响应可⽤的情况下.

{% note default orange simple %} 500 Internal Server Error.服务器遇到某个未曾预料的状况,导致它无法完成对请求的处理.{% endnote %}
一般来说,这个问题都会在服务器的程序码出错时出现.

{% note default orange simple %} 502 Bad Gateway.作为网关或代理工作的服务器尝试执行请求时,从上游服务器接收到无效的响应.{% endnote %}

{% note default orange simple %} 503 Service Unavailable.由于临时的服务器维护或过载,服务器当前无法处理请求.这个状况是临时的,{% endnote %}
并且将在一段时间以后恢复.503状态码的存在并不意味着服务器在过载的时候必须使用它.
某些服务器只不过是希望拒绝客户端的连接.

{% note default orange simple %} 504 Gateway Timeout作为网关或代理工作的服务器尝试执行请求时,未能及时从上游服务器(URI标识出的服务器,{% endnote %}
例如HTTP,FTP,LDAP)或辅助服务器(例如DNS)收到响应
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
