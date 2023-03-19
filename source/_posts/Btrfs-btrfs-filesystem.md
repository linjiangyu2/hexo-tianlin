---
title: Btrfs
description: Btrfs
categories:
  - 运维
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/links.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/links.jpg'
businesscard: true
comments: 'yes'
url: /archives/btrfs-filesystem
tags:
  - Linux
abbrlink: ad929b66
date: 2022-09-21 09:38:55
updated: 2022-09-23 09:06:11
---

### btrfs

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
#### 1.特性
{% endnote %}
{% endwow %}

{% note default orange simple %} 可由多个块设备组合成一个btrfs文件系统，多物理卷支持{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 支持RAID(0,1,5,6,10),dup(冗余),single(单盘)和热更新{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 写时复制更新机制(Cow): 复制、更新及替换指针，而非就地更改源文件{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 支持元数据校验码机制，一旦文件计算后发现受损会自动尝试修复{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 支持创建子卷(子卷本质是在btrfs文件系统中由btrfs创建的一个文件夹，可以单独被拿出来挂载到别的某一个目录中){% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 快照，还支持快照的快照（可以实现快照的增量备份）{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 透明压缩（无需用户参与）{% endnote %}
{% note default orange simple %}{% endnote %}
{% note default orange simple %} 支持ext4的文件系统转换为btrfs{% endnote %}

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
#### 2.btrfs
{% endnote %}
{% endwow %}

#### 2.1 mkfs.btrfs

```powershell
-L         label
# mkfs.btrfs -L btr1 /dev/sdf /dev/sdg        //把/dev/sdf,sdg格式化成btrfs系统并打上btr1的标签
-d [type]  raid0,1,5,6,10,single
-m <profile> raid0,1,5,6,10,single,dup(冗余)
-O <feature>
    -O list-all   列出支持的所有的feature
```

#### 2.2 btrfs

```powershell
# btrfs filesystem show        			//查看btrfs文件系统的块设备

# btrfs filesystem show -m(--mounted) -d(--all) 		//查看已挂载的btrfs文件系统的设备

# btrfs filesystem label /dev/xxx        //查看设备的label标签

透明压缩机制,所有文件的读取和写入会经过解压缩处理
# mount -o compress=lzo /dev/xxx xxx(path)
或者
# mount -o compress=zlib /dev/xxx xxx(path)

# btrfs filesystem resize -10G /btr1       //把挂载在/btr1目录的btrfs文件系统块设备缩减10G空间

# btrfs filesystem resize +5G /btr1       //把挂载在/btr1目录的btrfs文件系统块设备增加5G空间

# btrfs filesystem resize max /btr1       //把挂载在/btr1目录的btrfs文件系统块设备增加到目前最大的存储空间 

# btrfs filesystem df /btr1       // -m -g -k 以什么磁盘单位查看挂载在/btr1下的btrfs文件系统信息

# btrfs device add /dev/sdh /btr1   //把/dev/sdh设备添加到挂载在/btr1目录的btrfs文件系统中

因为文件系统不会自动把前面存储的数据平衡到每一块硬盘块设备中,为了能让新加入的数据盘能均衡平躺存储,应该手动把数据平衡到每个存储盘中
# btrfs balance start /btr1    //加上--full-balance执行可以不经过等待立刻执行,不然会有倒计时10秒后执行
btrfs balance [option] directory
			  start    开始
	  		  pause    暂停
	  		  cancel   取消
	  		  resume   继续
	  		  status   状态
	  		  
# btrfs device delete /dev/sdh /btr1      //把/dev/sdh设备从挂载在/btr1目录的btrfs文件系统中移除（移除时会自动把要移除的设备中的数据移动到其他的属于该原本btrfs文件系统的设备中去）
如果移除操作会导致磁盘少于指定的RAID级别最低要求数,则会无法移除

# btrfs balance start -mconvert=raid(0,1,5,6,10,dup.single) /btr1  //修改挂载在/btr1的btrfs文件系统的元数据RAID级别(一定要达到本来RAID级别所需要的最少磁盘个数)

# btrfs balance start -dconvert=raid(0,1,5,6,10,dup.single) /btr1  //修改挂载在/btr1的btrfs文件系统的数据RAID级别(一定要达到本来RAID级别所需要的最少磁盘个数)

创建子卷
# btrfs subvolume create /btrfs/logs
查看挂载在/btr1目录下的btrfs文件系统的子卷
# btrfs subvolume list /btrfs

# mount -o subvol=logs(可以换成卷ID) /dev/sdf /mnt     //把/dev/sdf中的子卷logs挂载到/mnt目录下

# btrfs subvolume delete /btr1/cache        //把挂载在/btr1下的btrfs文件系统的cache子卷删除

创建子卷快照(子卷的快照必须在文件系统的挂载目录下)
# btrfs subvolume snapshot /btr1/logs /btr1/logs_snapshot      //创建挂载在/btr1下的btrfs文件系统的logs子卷的快照为logs_snapshot

# 支持单文件快照
# cp --reflink /btr1/passwd /btr1/passwd_snapshot
```

#### 3.example

{% note default orange simple %} 环境{% endnote %}

```powershell
# lsblk
sdf                   8:80   0   20G  0 disk  
sdg                   8:96   0   20G  0 disk  
sdh                   8:112  0   20G  0 disk  
sdi                   8:128  0   20G  0 disk  
sdj                   8:144  0   20G  0 disk  
sdk                   8:160  0   20G  0 disk 
```

```powershell
# mkfs.btrfs -L btr1 /dev/sdf /dev/sdg        //把/dev/sdf,sdg格式化成btrfs系统并打上btr1的标签
# btrfs filesystem show        //查看btrfs文件系统的块设备
Label: 'btr1'  uuid: f1713d01-0741-41d5-9062-87e46bbad575
        Total devices 2 FS bytes used 112.00KiB
        devid    1 size 20.00GiB used 2.01GiB path /dev/sdf
        devid    2 size 20.00GiB used 2.01GiB path /dev/sdg
这里已经是一个可以挂载的类型是btrfs文件系统的块设备了,尝试挂载一下
# mkdir /btr1
# mount -t btrfs /dev/sdf /btr1 
# df -Th /btr1
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sdf       btrfs   40G   18M   38G   1% /btr1
可以看到是两个块设备绑定在了一块显示的是可用40G存储

# 在线缩小存储空间,块设备必须先挂载到目录上
# btrfs filesystem resize -10G /dev/sdf       //把挂载在/btr1目录的btrfs文件系统块设备缩减10G空间
Resize '/btr1' of '-10G'

# df -hT /btr1
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sdf       btrfs   30G   18M   18G   1% /btr1

# btrfs filesystem df /btr1       // -m -g -k 以什么磁盘单位查看挂载在/btr1下的btrfs文件系统信息
Data, RAID0: total=2.00GiB, used=788.00KiB
System, RAID1: total=8.00MiB, used=16.00KiB
Metadata, RAID1: total=1.00GiB, used=112.00KiB
GlobalReserve, single: total=16.00MiB, used=0.00B

# btrfs filesystem resize max /btr1       //把挂载在/btr1目录的btrfs文件系统块设备增加到目前最大的存储空间 

# df -Th /btr1
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sdf       btrfs   40G   18M   38G   1% /btr1

# btrfs device add /dev/sdh /btr1   //把/dev/sdh设备添加到挂载在/btr1目录的btrfs文件系统中
# df -Th /btr1
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sdf       btrfs   60G   18M   56G   1% /btr1

因为文件系统不会自动把前面存储的数据平衡到每一块硬盘块设备中,为了能让新加入的数据盘能均衡平躺存储,应该手动把数据平衡到每个存储盘中
# btrfs balance start /btr1    //加上--full-balance执行可以不经过等待立刻执行,不然会有倒计时10秒后执行
Starting balance without any filters.
Done, had to relocate 3 out of 3 chunks
# btrfs device delete /dev/sdh /btr1      //把/dev/sdh设备从挂载在/btr1目录的btrfs文件系统中移除（移除时会自动把要移除的设备中的数据移动到其他的属于该原本btrfs文件系统的设备中去）

# df -hT /btr1
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sdf       btrfs   40G   18M   40G   1% /btr1

修改数据和元数据的RAID级别(动态更新)
# btrfs balance start -mconvert=raid(0,1,5,6,10,dup.single) /btr1  //修改挂载在/btr1的btrfs文件系统的元数据RAID级别(一定要达到本来RAID级别所需要的最少磁盘个数)

# btrfs balance start -dconvert=raid(0,1,5,6,10,dup.single) /btr1  //修改挂载在/btr1的btrfs文件系统的数据RAID级别(一定要达到本来RAID级别所需要的最少磁盘个数)

创建子卷
# btrfs subvolume create /btrfs/logs
查看挂载在/btr1目录下的btrfs文件系统的子卷
# btrfs subvolume list /btrfs
# btrfs subvolume create /btrfs/cache
# ls /btr1
cache  logs
# cp /etc/passwd /btr1/logs/
# mount -o subvol=logs(可以换成卷ID) /dev/sdf /mnt     //把/dev/sdf中的子卷logs挂载到/mnt目录下
# df -Th 
/dev/sdf                btrfs      60G   17M   58G   1% /mnt
/dev/sdf                btrfs      60G   17M   58G   1% /btr1
# ls /mnt
passwd

删除子卷
# btrfs subvolume delete /btr1/cache        //把挂载在/btr1下的btrfs文件系统的cache子卷删除
Delete subvolume (no-commit): '/btr1/cache'

创建子卷快照(子卷的快照必须在文件系统的挂载目录下)
# btrfs subvolume snapshot /btr1/logs /btr1/logs_snapshot      //创建挂载在/btr1下的btrfs文件系统的logs子卷的快照为logs_snapshot

# 支持单文件快照
# cp --reflink /btr1/passwd /btr1/passwd_snapshot

```

{% note default orange simple %} 把ext4文件系统转换为btrfs文件系统{% endnote %}

```powershell
# mke2fs -t ext4 /dev/sdj
# mount /dev/sdj /mnt
# cp /etc/passwd /mnt/
# umount /mnt
# e2fsck -f /dev/sdj 或者 # fsck -f /dev/sdj
# btrfs-convert /dev/sdj
# mount /dev/sdj /mnt
# ls /mnt
ext2_saved  passwd  lost+found
*这个ext2_saved文件夹不能删除

还可以重新把文件系统回滚到ext4(但是转换为btrfs之后操作的文件不会修改和保留,类似于回滚快照)
# umount /mnt
# btrfs-convert -r /dev/sdj
rollback complete
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
