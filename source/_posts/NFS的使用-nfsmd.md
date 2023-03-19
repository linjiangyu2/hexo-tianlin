---
title: NFS的使用
description: NFS的使用
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/nfs.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/nfs.jpg'
businesscard: true
comments: 'yes'
url: /archives/nfsmd
tags:
  - Linux
abbrlink: 1309af80
date: 2022-09-06 12:07:31
updated: 2022-09-23 09:07:55
---

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
一、NFS的使用
{% endnote %}
{% endwow %}

{% note default orange simple %} nfs是对服务器的文件夹共享，属于NAS中的一中，可以实现多个服务器读写共享文件{% endnote %}

####  1.环境

|    IP     | HOSTNAME |  ROLE  |
| :-------: | :------: | :----: |
| 10.10.0.1 |   nfs    | server |
| 10.10.0.2 |  client  | client |

####  2.使用

```shell
[root@ nfs,client]# cat > /etc/hosts <<END
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.10.0.1	nfs
10.10.0.2	client
END
```

```powershell
[root@ nfs]# yum install -y nfs-utils rpcbind
[root@ client]# yum install -y nfs-utils
[root@ nfs]# mkdir /nfs         //创建一个目录用于测试
[root@ nfs]# echo 'nfs test' > /nfs/t1
[root@ nfs]# vim /etc/exports   //nfs服务的主配置文件，nfs的下载不会自动创建这个文件
/nfs/data	*(rw,sync,no_root_squash)     //*代表所有的IP都可以访问挂载
#文件的编写
共享主机：
*   ：代表所有主机
10.10.0.0/24：代表共享给某个网段10.10.0.1 ~ 10.10.0.254
10.10.0.0/24(rw) 10.10.1.0/24(ro) :代表共享给不同网段
10.10.0.10：共享给某个IP
*.linjiangyu.com:代表共享给某个域下的所有主机

共享选项：
ro：只读
rw：读写
sync：实时同步，直接写入磁盘(安全性最高)
async：异步，先缓存数据在内存然后再同步磁盘(效率最高，但是有丢失文件风险)
anonuid：设置访问nfs服务的用户的uid，uid需要在/etc/passwd中存在
anongid：设置访问nfs服务的用户的gid
root_squash ：默认选项 root用户创建的文件的属主和属组都变成nfsnobody,其他人nfs-server端是它自己，client端是nobody。(访问NFS服务器时，映射为匿名账号)
no_root_squash：root用户创建的文件属主和属组还是root，其他人server端是它自己uid，client端是nobody。(访问NFS服务器时，映射为root管理员账号)
all_squash： 不管是root还是其他普通用户创建的文件的属主和属组都是nfsnobody

说明：
anonuid和anongid参数和all_squash一起使用。
all_squash表示不管是root还是其他普通用户从客户端所创建的文件在服务器端的拥有者和所属组都是nfsnobody；服务端为了对文件做相应管理，可以设置anonuid和anongid进而指定文件的拥有者和所属组
[root@ nfs]# exportfs -rv  //显示当前nfs的共享
exporting *:/nfs/data
```

```powershell
[root@ client]# showmount -e nfs   //查看主机的共享文件夹
Export list for nfs:
/nfs *
[root@ client]# mkdir /nfs/data 
[root@ client]# mount.nfs nfs:/nfs/data /nfs  //把nfs服务器的文件夹挂载在/nfs上
[root@ client]# df -Th /nfs   //查看挂载
Filesystem     Type  Size  Used Avail Use% Mounted on
nfs:/nfs/data       nfs4   15G   66M   15G   1% /nfs
[root@ client]# ls /nfs
t1
[root@ client]# cat /nfs/t1
nfs test
```

{% note default orange simple %} 每次的重启服务器都要重新挂载，所以我们要写在/etc/fstab文件中实现自动开机挂载{% endnote %}

```shell
[root@ nfs]# vim /etc/fstab
nfs:/nfs/data	/nfs	nfs		rw,sync,no_root_squash		0 0
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
二、自动挂卸载的实现
{% endnote %}
{% endwow %}

####  autofs的使用

```shell
[root@ client]# yum install autofs -y 
[root@ client]# mkdir /nfs
[root@ client]# vim /etc/exports
/nfs/data	*(rw,sync,no_root_squash)
[root@ client]# vim /etc/auto.master
# 添加
/nfs    /etc/auto.nfs -t 120    //-t 120是表示在120秒内无操作自动卸载
[root@ client]# cp /etc/auto.misc /etc/auto.nfs
[root@ client]# vim /etc/auto.nfs
data		-fstype=nfs,rw,sync,no_root_squash		nfs:/nfs/data
[root@ client]# systemctl start autofs
[root@ client]# df -Th   
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 898M     0  898M   0% /dev
tmpfs                    910M     0  910M   0% /dev/shm
tmpfs                    910M  9.6M  901M   2% /run
tmpfs                    910M     0  910M   0% /sys/fs/cgroup
/dev/mapper/centos-root   15G   66M   15G   1% /
/dev/mapper/centos-usr    24G  1.6G   22G   7% /usr
/dev/sr0                 9.5G  9.5G     0 100% /iso
/dev/sda1                759M  151M  609M  20% /boot
/dev/mapper/centos-home   15G   33M   15G   1% /home
/dev/mapper/centos-tmp   3.8G   33M  3.7G   1% /tmp
/dev/mapper/centos-var    15G  890M   15G   6% /var
tmpfs                    182M     0  182M   0% /run/user/0
# 是不会出现nfs的挂载的
[root@ client]# cd /nfs
[root@ client]# ls
# 发现是无内容的
[root@ client]# cd data //进去了
[root@ client]# ls 
t1
[root@ client]# df -Th ./
nfs:/nfs/data  nfs4   15G   66M   15G   1% /nfs/data
[root@ client]# cd
# 等待120分钟,df -Th，会发现已经卸载
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
三、使用ansible-playbook的自动化搭建
{% endnote %}
{% endwow %}

{% note default orange simple %} 环境:{% endnote %}
```
[root@ master]# vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.222.150 master
192.168.222.151 node1
192.168.222.152 node2
[root@ master]# yum install -y ansible
[root@ master]# for i in master node{1..2};do ssh-copy-id $i;done
[root@ master]# vim /etc/ansible/hosts
[demo]
master
node1
node2
```
{% note default orange simple %} example:{% endnote %}
```
[root@ master]# vim ./t1.yaml
- hosts: master
  remote_user: root
  tasks:
  - name: install nfs packages
    yum: name={{ item }} state=latest
    with_items:
    - nfs-utils
    - rpcbind
    when: ansible_os_family == "RedHat"
  - name: mkdir /nfs
    file: path=/nfs state=directory
  - name: nfs conf setting
    copy: content="/nfs *(rw,sync,no_root_squash)" dest=/etc/exports
    notify: restart nfs.service
  handlers:
  - name: restart nfs.service
    service: name={{ item }} state=restarted
    with_items:
    - nfs
    - rpcbind
- hosts: node
  remote_user: root
  tasks:
  - name: /etc/hosts file
    copy: src=/etc/hosts dest=/etc/hosts force=yes
  - name: install nfs client package
    yum: name=nfs-utils state=latest
  - name: mkdir mount directory
    file: path=/nfs state=directory
  - name: client nfs-server
    command: "mount.nfs master:/nfs /nfs"
[root@ master]# ansible-playbook ./t1.yaml
```
{% note default orange simple %} 已经是搭建好了，到各工作节点查看{% endnote %}
```
[root@ node1,2]# df -h /nfs
master:/nfs               15G  465M   15G   4% /nfs
```

![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
