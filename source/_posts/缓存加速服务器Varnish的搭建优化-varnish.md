---
title: 缓存加速服务器Varnish的搭建优化
description: 缓存加速服务器Varnish的搭建优化
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/varnish.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/varnish.jpg'
businesscard: true
comments: 'yes'
url: /archives/varnish
tags:
  - Linux
abbrlink: 6373edb1
date: 2022-09-04 00:01:30
updated: 2022-09-13 17:10:26
---

## 1.变量类型

```
内建变量：
	req.*:request	表示由客户端发来的请求报文
		req.http.*
			req.http.User-Agent,req.http.Rederer,...
		bereq.*		由varnish发往BE主机的httpd请求相关
			bereq.http.*
		beresp.*	由BE主机响应给varnish的响应报文相关
			beresp.http.*
		resp.*		由varnish响应给client相关
		obj.*		存储在缓存空间中的缓存对象的属性(只读)
```

```
常用变量：
		bereq.*, req.*：
		bereq.http.HEADERS
		bereq.request：请求方法；
		bereq.url：请求的url；
		bereq.proto：请求的协议版本；
		bereq.backend：指明要调用的后端主机；				
		req.http.Cookie：客户端的请求报文中Cookie首部的值； 
		req.http.User-Agent ~ "chrome"
		
		beresp.*, resp.*：
		beresp.http.HEADERS
		beresp.status：响应的状态码；
		reresp.proto：协议版本；
		beresp.backend.name：BE主机的主机名；
		beresp.ttl：BE主机响应的内容的余下的可缓存时长；
						
		obj.*
		obj.hits：此对象从缓存中命中的次数；
		obj.ttl：对象的ttl值
		server.*
				server.ip
				server.hostname
		client.*
				client.ip
```


### Command.

```
-s  [name=]type,[options]   //设置varnish的缓存机制(Storage Types):
	
	malloc[,size]   //内存存储,[size]用于定义空间大小(重启后所有缓存失效)
	
	file[,path,[size[,granularlty]]] //磁盘存储,黑盒；(重启失效)//建议
	
	perslstent,path,size  //文件存储,黑盒；(重启后缓存有效) //(实验)
```

```
varnish程序的选项：
	程序选项： /etc/varnish/varnish.params文件
		-a  address[:port][,address[:port]][...] 默认端口为6081
		-T	address[:port] 默认端口为6082
		-s	[name=]type[,options] 定义缓存存储机制
		-u	user
		-g	group
		-f	config	VCL配置文件
		-F	运行于前台
		...
	运行时参数： /etc/varnish/varnish.params文件,DEAMON_OPTS
		DAEMON_OPTS="-p thread_pool_min=5 -p thread_pool_max=500 -p thread_pool_timeout=300"
		-p	param=value:设定运行参数及其值；可重复使用多次
		-r	param[,param...]:设定指定的参数为只读状态
```

```
# varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082

#> vcl.list    #查看已有策略组

#> vcl.use xxx  #使用已有的策略组

#> vcl.load 组名 /etc/varnish/default.vcl  #从文件加载策略组
```



```
[root@ varnish]# yum install varnish -y
[root@ varnish]# cd /etc/varnish
[root@ varnish]# vim varnish.params
VARNISH_LISTEN_PORT=80 #把默认值修改为80

VARNISH_STORAGE="file,/data/varnish.db,10g"   #修改缓存策略,指定缓存文件为/data/varnish.db，限制内存为10g

保存
[root@ varnish]# systemctl enable --now varnish
#这个时候服务起来了但是访问localhost是会显示错误的，因为vcl还没设置
[root@ varnish]# vim /etc/varnish/default.vcl
backend default {
    .host = "WEB服务器的IP";
    .port = "WEB服务器端口";
}
[root@ varnish]# varnish_reload_vcl
[root@ varnish]# varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082 //进入命令行
```

{% note default orange simple %} 筛选规则写在default.vcl中的sub vcl_deliver段{% endnote %}

## example：

####  1.简单cache服务器搭建



| HOSTNAME |             IP             |         GATEWAY         |
| :------: | :------------------------: | :---------------------: |
|  cache   | 10.10.0.10,192.168.222.236 | 10.10.0.2,192.168.222.2 |
|  client  |         10.10.0.20         |       10.10.0.10        |
|   web    |      192.168.222.232       |     192.168.222.236     |

{% note default orange simple %} cache也类似做了一个路由器的作用（所以需要打开路由转发功能）{% endnote %}

```
[root@ cache]# sed -i '$anet.ipv4.ip_forward = 1' >> /etc/sysctl.conf
[root@ cache]# sysctl -p
```

{% note default orange simple %} 配置一个简单的Web服务器{% endnote %}

```
[root@ web]# yum install -y httpd
# 随便往/var/www/html里面扔点网页文件
```

{% note default orange simple %} 配置cache服务器{% endnote %}

```
[root@ cache]# yum install -y varnish
[root@ cache]# mkdir -p /data/cache
[root@ cache]# cd /etc/varnish
[root@ cache]# vim varnish.params   //修改以下两项为
VARNISH_LISTEN_PORT=80
VARNISH_STORAGE="file,/data/cache,10g"   //缓存策略改为file存储,指定目录,存储空间
[root@ cache]# vim /etc/varnish/default.vcl  //修改两项为
backend default {
    .host = "web";
    .port = "80";
}
#添加返回响应在sub vcl_deliver段
sub vcl_deliver {
	if (obj.hits>0) {
        set resp.http.X-Cache = "HIT cache " + server.ip;
	}else {
	    set resp.http.X-Cache = "MISS cache " + server.ip;
	}
}
```

```
[root@ cache]# systemctl start varnish
[root@ cache]# varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082
#> vcl.list  //查看当前使用和拥有的策略组
#> vcl.load t1 /etc/varnish/default.vcl   //从文件载入策略组
#> vcl.use t1   //使用t1策略组
```

{% note default orange simple %} 已经可以尝试浏览器访问10.10.0.10了，使用F12查看缓存的命中，状态码304即是已缓存响应，第二次访问可看到X-Cache: Hit cache 192.168.222.232{% endnote %}

####  2.设置不被命中规则
```
[root@ web]# mkdir /var/www/html/{admin,login}
[root@ web]# echo "login sucessful" > /var/www/html/login/index.html
[root@ web]# echo "admin varnish test" > /var/www/html/admin/index.html

[root@ cache]# vim /etc/varnish/default.vcl
#在sub vcl_recv段加上命中规则,让admin和login路径不进行缓存
sub vcl_recv {
	if (req.url ~ "(?i)^/(login|admin)") {
    	return(pass);
	}
```
```
[root@ cache]# varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082
#> vcl.load t2 /etc/varnish/default.vcl
#> vcl.use t2
```
{% note default orange simple %} 进入浏览器打开F12访问http://10.10.0.10/admin或者http://10.10.0.10/login,多次刷新发现都没有缓存{% endnote %}
{% note default orange simple %} 显示X-Cache: MISS cache10.10.0.50  //未命中{% endnote %}

...持续更新中
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
