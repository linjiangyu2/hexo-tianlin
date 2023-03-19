---
title: safe-rm
description: safe-rm
categories:
  - 运维
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/saferm.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/saferm.jpg'
businesscard: true
comments: true
tags:
  - Linux
abbrlink: 87519fc9
date: 2022-11-20 00:25:10
---

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
safe-rm
{% endnote %}
{% endwow %}

{% checkbox orange checked, 看名字就能知道是什么了，安全的rm命令 %}

{% note default orange simple %}比rm命令增加的功能，skip Directory or file{% endnote %}

{% folding cyan open, 这里使用的二进制包 %}   

{% link safe-rm.tar.gz,https://alist.linjiangyu.com/d/Linux/safe-rm-0.12.tar.gz ,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}  

```shell
# tar xf safe-rm.tar.gz
# cd safe-rm-0.12
# chown root. safe-rm
# mv safe-rm /usr/local/bin/rm
# vim /etc/profile
export PATH=/usr/local/bin:$PATH
# source /etc/profile
```

{% note default orange simple %}编写一下禁止删除的文件或文件夹{% endnote %}

```shell
# touch /opt/t1                    // 测试文件
# vim /etc/safe-rm.conf         // 这个文件是自己创建的,safe-rm会默认去找这个文件的规则
/
/*
/etc
/etc/*
/usr
/usr/local
/usr/local/bin
/usr/local/bin/*
/root
/root/*
/opt/t1         # 为了测试
# rm -f /opt/t1  
safe-rm: skipping t1
# 会无法删除,把/etc/safe-rm.conf中的/opt/t1删除后再rm -f /opt/t1便可删除
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
