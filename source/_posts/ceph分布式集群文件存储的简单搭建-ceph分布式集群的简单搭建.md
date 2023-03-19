---
title: ceph分布式集群文件存储的简单搭建
description: ceph分布式集群文件存储的简单搭建
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/ceph.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/ceph.jpg'
businesscard: true
comments: 'yes'
url: /archives/ceph分布式集群的简单搭建
tags:
  - Linux
abbrlink: '829779e4'
date: 2022-08-04 14:59:10
updated: 2022-09-13 17:10:45
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
ceph集群搭建
{% endnote %}
{% endwow %}

环境
{% note default orange simple %}node1:192.168.222.246{% endnote %}
node2:192.168.222.249
node3:192.168.222.211
client:192.168.222.141
写入每个机器的/etc/hosts文件

{% note default orange simple %}推荐在三节点的任意一台做全部机器的ssh免密，这里我在node1上完成。{% endnote %}

{% note default orange simple %}一、环境准备{% endnote %}
给每个node节点加上一块硬盘，不能是逻辑卷，这里我的三个设备的都是/dev/sdb
修改主机名，必须与hosts文件一致
systemctl disable --now firewalld NetworkMnager //这里是测试关闭防火墙，有需要的开启6789,3300,6800.7300端口
selinux关闭
上传ceph.repo文件，最好使用国内的镜像源，不让速度会很慢
server端：yum install -y ntp ceph ceph-radosgw
client端：yum install -y ceph ceph-common
node1: yum install -y ceph-deploy
echo "systemctl restart ntpd" >> /etc/rc.local
#最好在加上for i in node{1..3};do echo "*/10 * * * * systemctl restart ntpd" >> /var/spool/cron/root 
#我当前的测试是在root下进行，可自己更换，因为ceph集群对于时间同步的要求十分严格


{% note default orange simple %}二、开始配置，在node1上操作{% endnote %}
```shell
for i in node{1..3};do ssh $i mkdir /etc/ceph;done  //官方有些版本没有固定的配置文件目录，自己创建一下
cd /etc/ceph
ceph-deploy new node1  //创建集群，这里可以看到当前目录已经有了三个配置文件
for i in node{1..3};do ssh $i yum install -y ceph ceph-radosgw;done    //下载软件，这里官方是使用
ceph-deploy install node2 node3来通过官方下载的，但是一般会出问题，因为是外国的网站，所以我们自己
上传国内的ceph.repo在节点上然后下载
echo "public network = 192.168.222.0/24" >> ./ceph.conf     //监控网络
ceph-deploy mon create-initial     //创建初始化mon
ceph-deploy admin node{1..3}    //同步配置文件到每个节点
ceph-deploy mon add node{2..3}   //可加可不加，类似做了mon的HA，建议奇数个，因为有quorum的仲裁投票
ceph -s    //查看集群状态
ceph config set mon auth_allow_insecure_global_id_reclaim false  //关闭不安全提示
ceph -s
在ceph.conf文件加上
mon clock drift allowed = 2         //monitor间的时间滴答数（默认为0.5秒）
mon clock drift warn backoff = 30   //警告时间允许的偏移量（默认为5秒） #这里我试过了1秒的偏移，系统警告了
ceph-deploy --overwrite-conf admin node{1..3}  //记得每次修改完配置文件都要同步到每个节点
for i in node{1..3};do ssh $i systemctl restart ceph-mon.target;done  //重启每个节点的服务，让配置生效
#创建mgr(管理)
#ceph luminous版本中新增加了一个组件：Ceph Manager Daemon，简称ceph-mgr,该组件的主要作用是分担和扩展monitor的部分功能，减轻monitor的负担，让更好地管理ceph存储系统
ceph-deploy mgr create node1
#这里是为了实现HA,把node2,node3也做mgr
ceph-deploy mgr create node2
ceph-deploy mgr create node3
ceph -s 
#可以看到mgr以node1为主节点，node2,node3为备
#然后创建osd存储盘
ceph-deploy disk list node{1..3}  //查看节点上的磁盘
ceph-deploy disk zap node1 /dev/sdb   //初始化磁盘，类似格式化
ceph-deploy disk zap node2 /dev/sdb
ceph-deploy disk zap node3 /dev/sdb
#将磁盘创建为osd
ceph-deploy osd create --data /dev/sdb node1
ceph-deploy osd create --data /dev/sdb node2
ceph-deploy osd create --data /dev/sdb node3
ceph -s 可以看到已经加了三个osd
#（扩容方式：假设要加入一台node4，先写入hosts文件和同步文件和主机名，做ssh免密，然后yum install ceph ceph-radosgw ntp (rsync)），关闭selinux,NetworkManager,firewalld，写入定时任务同步时间，在node1操作ceph-deploy admin node4，按需求选择在node4上添加mon,mgr,osd等等）
尝试创建pool并使用删除2的倍数，与osd的数量有关，一般5个osd以下的，分128的pg即可，多了会报错，可以适当通过报错调整pg数
注释：pg数为
ceph osd pool create test 128  //创建一个名为test的pg数为128的pool
ceph osd pool get test pg_num  //查看test的pg数
#ceph osd pool set test pg_num 64   //可以使用此命令把test的pg数从128改为64，此处不执行
使用存储测试
rados put testfile /etc/fstab --pool=test   //上传/etc/fstab文件到test pool中作为testfile
rados -p test ls           //查看test pool的根文件
rados rm testfile --pool=test     //删除 test pool里面的testfile
删除pool
在配置文件写下允许删除pool的参数，默认是不允许删除
vim ./ceph.conf
加入
mon_allow_pool_delete = true
然后同步配置文件
ceph-deploy --overwrite-conf admin node{1..3}
重启监控服务让配置生效
for i in node{1..3};do ssh $i systemctl restart ceph-mon.target;done
删除test pool
ceph osd pool delete test test --yes-i-really-really-mean-it    //这里要输入两次pool名
创建文件存储并在client端连接使用
创建mds服务，多个是HA，我这里还是全部加上
ceph-deploy mds create node{1..3}
注释：一个ceph文件系统需要至少两个rados存储池，一个是数据另一个是元数据
ceph osd pool create cephfs_pool 128
ceph osd pool create cephfs_cache 64
查看一下
ceph osd pool ls
创建ceph文件系统
ceph fs new cephfs cephfs_pool cephfs_cache  //以上面两个pool创建文件系统cephfs
查看一下
ceph fs ls
ceph mds stat

给客户端加上认证文件
cat ./ceph.client.admin.keyring

在client的下
echo “AQDEKlJdiLlKAxAARx/PXR3glQqtvFFMhlhPmw==” > /root/key
mkdir /root/test  //测试挂载目录
挂载
mount.ceph node1:6789,node2:6789,node3:6789:/ /root/test -o name=admin,secretfile=/root/key   // 这里要挂载多个monitor节点，避免因为只挂载的一个节点宕机了影响客户端使用
sed -i '$anode1:6789,node2:6789,node3:6789:/	/root/test		ceph		name=admin,secretfile=/root/key'  /etc/fstab    //开机自动挂载
df -h 查看
以上一个文件存储便搭建完毕，可以正常使用了
二、删除文件存储方法
在client端删除数据并卸载
rm -rf /root/test/* && umount /root/test
停掉所有server端的mds（不然是无法删除文件存储的）
for i in node{1..3};do ssh $i systemctl stop ceph-mds.target;done
ceph fs rm cephfs --yes-i-really-mean-it  //删除文件系统cephfs
ceph osd pool delete cephfs_pool cephfs_pool --yes-i-really-really-mean-it  //删除pool中的cephfs_pool，记得是写两次pool的名字
ceph osd pool delete cephfs_cache cephfs_cache --yes-i-really-really-mean-it //删除pool中的cephfs_cache
删完再重新启动mds服务
for i in node{1..3};do ssh $i systemctl start ceph-mds.target
sed -i '$d' /etc/fstab   //删除后别忘记删除fstab文件中的加入
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
