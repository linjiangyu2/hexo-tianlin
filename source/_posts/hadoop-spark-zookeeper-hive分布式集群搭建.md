---
title: hadoop+spark+zookeeper+hive分布式集群搭建
description: hadoop+spark+zookeeper+hive分布式集群搭建
categories:
  - 服务集群
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/hive.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/hive.jpg'
businesscard: true
sticky: 9
comments: 'yes'
url: /archives/hive
abbrlink: b10cf3a3
date: 2022-11-18 08:42:26
tags:
---
{% timeline 大数据服务合集,orange %}

<!-- timeline 2022-09-01 [hadoop+spark](https://www.linjiangyu.com/2022/09/01/hadoop-spark%E5%88%86%E5%B8%83%E5%BC%8F%E6%90%AD%E5%BB%BA/) -->
hadoop+spark初识
<!-- endtimeline -->

<!-- timeline 2022-11-11 [zookeeper](https://www.linjiangyu.com/2022/11/11/hadoop-spark-zookeeper%E5%88%86%E5%B8%83%E5%BC%8F%E9%9B%86%E7%BE%A4%E6%90%AD%E5%BB%BA/) -->
向集群加入了zookeeper分布式
<!-- endtimeline -->

<!-- timeline 2022-11-19 [hive](https://www.linjiangyu.com/2022/11/18/hadoop-spark-zookeeper-hive%E5%88%86%E5%B8%83%E5%BC%8F%E9%9B%86%E7%BE%A4%E6%90%AD%E5%BB%BA/) -->
这里也写了适配CentOS6.x的配置
<!-- endtimeline -->

{% endtimeline %}
{% folding cyan orang open, 大数据服务合集 %}
{% nota 大数据服务合集,hadoop+spark+zookeeper+hive分布式集群 %}
{% endfolding %}
2022-09-01hadoop和spark的初识{% referto '[1]','hadoop and spark' %}
2022-11-11添加了zookeeper分布式{% referto '[2]','zookeeper' %}
2022-11-19添加了结合Mariadb的hive数据库使用{% referto '[3]','hive' %}

{% referfrom '[1]','hadoop and spark分布式','https://www.linjiangyu.com/2022/09/01/hadoop-spark%E5%88%86%E5%B8%83%E5%BC%8F%E6%90%AD%E5%BB%BA/' %}
{% referfrom '[2]','zookeeper','https://www.linjiangyu.com/2022/11/11/hadoop-spark-zookeeper%E5%88%86%E5%B8%83%E5%BC%8F%E9%9B%86%E7%BE%A4%E6%90%AD%E5%BB%BA/' %}
{% referfrom '[3]','hive','https://www.linjiangyu.com/2022/11/18/hadoop-spark-zookeeper-hive%E5%88%86%E5%B8%83%E5%BC%8F%E9%9B%86%E7%BE%A4%E6%90%AD%E5%BB%BA/' %}


hadoop+spark+zookeeper+hive分布式集群部署

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### 环境准备
{% endnote %}
{% endwow %}

{% note default orange simple %} 环境的准备基于我写的初始化脚本,自用7.x系列的CentOS,老版本的就支持CentOS/Redhat6,7,8但是有点不完善，需要可以邮箱或者博客留言。{% endnote %}

|           os\ip           | hostname |                     block                      |
| :-----------------------: | :------: | :--------------------------------------------: |
| centos7.9 192.168.222.226 |  master  | rsmanager,datanode,namenode.snamenode,nmanager |
| centos7.9 192.168.222.227 |  node1   |           snamenode,nmnager,datanode           |
| centos7.9 192.168.222.228 |  node2   |             datanode,nmanager              |

{% tabs 初始化, 2 %}
<!-- tab 旧版 -->
{% checkbox times red checked, 国外服务器托管代码，可能被墙 %}
```shell
# git clone https://github.com/linjiangyu2/K.git   //可能会拉不下来，多拉几次就下来了，因为托管代码的服务器是国外的
# cd K
# cat README.md  //不会使用的要看一下这个文件，了解脚本需要输入的配置
# ./ksh  //依次输入你自己的配置，第一次使用这个脚本一定要看README.md文件
# 如果需要有时候改IP地址图方便的话，直接把ksh这个二进制的脚本放在/usr/bin下，便可以在全局执行了
# mv ksh /usr/bin/ksh
使用ksh初始化后，开始配置
```
<!-- endtab -->
<!-- tab 新版 -->
{% checkbox orange checked, 本站托管代码放心食用 %}
```shell
# curl -e https://linjiangyu.com -O https://cdn1.tianli0.top/gh/linjiangyu2/halo/archive/K.tar.gz
# tar xf K.tar.gz
# cd K
# cat README.md  //不会使用的要看一下这个文件，了解脚本需要输入的配置
# ./ksh  //依次输入你自己的配置，第一次使用这个脚本一定要看README.md文件
# 如果需要有时候改IP地址图方便的话，直接把ksh这个二进制的脚本放在/usr/bin下，便可以在全局执行了
# mv ksh /usr/bin/ksh
使用ksh初始化后，继续下文配置
```
<!-- endtab -->
<!-- tab 船新版 -->
{% checkbox orange checked, CDN托管放心食用 %}
```
# wget https://cdn.staticaly.com/gh/linjiangyu2/K@master/ksh
# chmod +x ./ksh
# ./ksh  //依次输入你自己的配置，第一次使用这个脚本一定要看https://github.com/linjiangyu2/K
# 如果需要有时候改IP地址图方便的话，直接把ksh这个二进制的脚本放在/usr/bin下，便可以在全局执行了
# mv ksh /usr/bin/ksh
使用ksh初始化后，继续下文配置
```
<!-- endtab -->
{% endtabs %}
{% note default orange simple %} 对应自己的IP地址，最好/etc/hosts的解析名和我一致，不然下面的配置文件需要自己对应自己的解析名修改{% endnote %}

```shell
[master]# 
cat > /etc/hosts <<END
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 
192.168.222.226 master
192.168.222.227 node1
192.168.222.228 node2
END
[master]# ssh-keygen -P '' -f ~/.ssh/id_rsa
[master]# for i in master node{1..2};do ssh-copy-id $i;done
[master]# for i in node{1..2};do rsync -av /etc/hosts root@$i:/etc/hosts;done
[master]# for i in master node{1..2};do ssh $i yum install -y openssl-devel;done
```

2.搭建

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### hadoop分布式
{% endnote %}
{% endwow %}

#### 上传jdk和hadoop的tar包
{% folding cyan open, 这里使用的二进制包 %}

{% link hadoop-2.8.5.tar.gz,https://alist.linjiangyu.com/d/Linux/hadoop-2.8.5.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}
{% link jdk-8u212-linux-x64.tar.gz,https://alist.linjiangyu.com/d/Linux/jdk-8u212-linux-x64.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}
#### 配置

```shell
  [master]# tar xf hadoop...  //不知道你使用的版本，写了...，以下也是，tab键或者对应修改就可以
  # ...是表示我不知道你使用的版本，自己改
  [root@ master]# tar xf jdk...
  [root@ master]# tar xf hadoop...
  [root@ master]# mv hadoop... /opt/hadoop285
  [root@ master]# mv jdk... /usr/local/jdk
  
# vim /etc/profile
export JAVA_HOME=/usr/local/jdk
export HADOOP_HOME=/opt/hadoop285
export PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native 
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH
  
# source !$
```

{% note default orange simple %} 以下是自己直接写入配置，在master服务器上进行{% endnote %}

```shell
# cd /opt/hadoop285/etc/hadoop
# vim hadoop-env.sh  //修改文件里面的export JAVA_HOME=${JAVA_HOME}为
export JAVA_HOME=/usr/local/jdk
# vim yarn-env.sh //修改前面有注释的export JAVA_HOME为
export JAVA_HOME=/usr/local/jdk
```
```xml
# vim core-site.xml
<configuration>
        <property>
                <name>hadoop.tmp.dir</name>
                <value>/opt/data</value>
        </property>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://master:9000</value>
        </property>
        <property>
                <name>hadoop.proxyuser.root.hosts</name>
                <value>*</value>
        </property>
        <property>
                <name>hadoop.proxyuser.root.groups</name>
                <value>*</value>
        </property>
</configuration>
```

```xml
# vim hdfs-site.xml
<configuration>
        <property>
                <name>dfs.replication</name>
                <value>1</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>/opt/data/hdfs/name</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>/opt/data/hdfs/data</value>
        </property>
</configuration>
```

```xml
# vim yarn-site.xml 

<configuration>
        <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>master</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
</configuration>
```

```xml
# cp mapred-site.xml.template mapred-site.xml
# vim mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

```shell
# vim slaves
master
node1
node2
```

{% note default orange simple %} 然后在master节点把配置发到各个节点{% endnote %}

```shell
[master]# for i in node{1..2};do rsync -av /usr/local/jdk root@$i:/usr/local/;done
# for i in node{1..2};do rsync -av /opt/hadoop285 root@$i:/opt/;done
# for i in node{1..2};do rsync -av /etc/profile root@$i:/etc/profile;done
然后到各个节点
[node1,2]# source /etc/profile
```

{% note default orange simple %} 在node1,2上操作，最后在master操作{% endnote %}

```shell
# hdfs namenode -format   //初始化
# ls -d /opt/data   //此文件夹产生就是初始化成功
```
{% note default orange simple %} 在master上操作{% endnote %}

```shell
[root@ master]# start-all.sh
```
{% note default orange simple %} 最后可以在各个节点使用jps命令查看各自的部件{% endnote %}

```shell
[root@ xxx]# jps
```
{% note default orange simple %} 当然web界面也可以访问的，浏览器访问192.168.222.226:8088和192.168.222.226:50070(对应自己IP地址){% endnote %}

{% note default orange simple %} 来尝试运行一下第一个hadoop分布式任务吧{% endnote %}

```shell
[root@ master]# hdfs dfs -put /etc/passwd /t1
[root@ master]# hadoop jar /opt/hadoop285/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.5.jar wordcount /t1 /output/00
[root@ master]# hdfs dfs -ls /output/00  //查看运行后的结果文件,运行后的数据在part-r-00000
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### spark分布式
{% endnote %}
{% endwow %}

{% note default orange simple %}下面开始搭建分布式spark{% endnote %}

{% folding cyan open, 这里使用spark的3.3.0版本 %}

{% link spark-3.3.0-bin-hadoop3.tgz,https://alist.linjiangyu.com/d/Linux/spark-3.3.0-bin-hadoop3.tgz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}


```shell
# 把spark包上传到机器上，然后到该包的目录，这里统一以spark-3.3.0-bin-hadoop3.tgz这个包为演示
[root@ master]# tar xf spark-3.3.0-bin-hadoop3.tgz
[root@ master]# mv spark-3.3.0-bin-hadoop3 /opt/spark
[root@ master]# vim /etc/profile
export PATH=/opt/spark/bin:/opt/spark/sbin:$PATH
[root@ master]# cd /opt/spark/conf
[root@ master]# mv spark-env.sh.template spark-env.sh
[root@ master]# vim spark-env.sh
export JAVA_HOME=/usr/local/jdk
export HADOOP_CONF_DIR=/opt/hadoop285/etc/hadoop
export SPARK_MASTER_IP=master   #对应自己的master机器IP或者master解析的域名，如果是按照我上面做的直接写master即可
export SPARK_WORKER_MEMORY=1024m
export SPARK_WORKER_CORES=2 
export SPARK_EXECUTOR_MEMORY=1024m
export SPARK_WORKER_INSTANCES=1
export SOARK_MASTER_PORT=7077
export SPARK_EXECUTOR_CORES=1
SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=hdfs://master:9000/spark_logs"
[root@ master]# cp spark-defaults.conf.template spark-defaults.conf
[root@ master]# vim spark-defaults.conf
spark.master                     spark://master:7077
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://master:9000/spark_logs
[root@ master]# vim slaves     //对应自己的三台主机IP地址或者解析的域名
master
node1
node2
[root@ master]# cd /opt/spark/sbin
[root@ master]# mv start-all.sh spark-start.sh
[root@ master]# mv stop-all.sh spark-stop.sh
[root@ master]# source /etc/profile
[root@ master]# scp -r /opt/spark root@node1:/opt/
[root@ master]# scp -r /opt/spark root@node2:/opt/
[root@ master]# scp -r /etc/profile root@node1:/etc/
[root@ master]# scp -r /etc/profile root@node2:/etc/
# 然后在各工作节点执行命令
[root@ node1,node2]# source /etc/profile
# 在master节点执行
[root@ master]# start-all.sh
[root@ master]# hdfs dfs -mkdir /spark_logs
[root@ master]# spark-start.sh  //启动spark集群
[root@ master]# jps     //查看
```
{% note default orange simple %} 以上便搭建好了spark结合hadoop的分布式集群，spark也有自己的web界面，可以浏览器访问192.168.222.226:8080来查看(对应自己IP地址){% endnote %}

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### zookeeper分布式
{% endnote %}
{% endwow %}

{% folding cyan open, 这里使用的二进制包 %}

{% link apache-zookeeper-3.5.10.tar.gz,https://alist.linjiangyu.com/d/Linux/zookeeper-3.4.14.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}

{% note default orange simple %} 在master机器上执行{% endnote %}

```shell
# tar xf zookeeper*
# mv zookeeper* /opt/zookeeper
# mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
# vim /opt/zookeeper/conf/zoo.cfg
修改
dataDir=/opt/data/zookeeper
添加
dataLogDir=/opt/data/zookeeper/logs
server.1=master:2888:3888
server.2=node1:2888:3888
server.3=node2:2888:3888
# 这里对应自己的主机名
```

{% note default orange simple %} 在各机器上执行{% endnote %}

```shell
# mkdir -p /opt/data/zookeeper/logs
# echo 1 > /opt/data/zookeeper/myid             #这里master对应上面的server.1 便要echo1,node1对应server.2便要echo 2,node3对应server.3便要echo 3
```

{% note default orange simple %} 在master机器上执行{% endnote %}

```shell
# vim /etc/profile
export ZOOKEEPER_HOME=/opt/zookeeper
export PATH=${ZOOKEEPER_HOME}/bin:$PATH
# for i in node{1..2};do rsync -av /opt/zookeeper root@$i:/opt/;done
# for i in node{1..2};do rsync -av /etc/profile /etc/;done
```

{% note default orange simple %} 在各机器上执行{% endnote %}

```shell
# source /etc/profile
# zkServer.sh start             #这个命令最好使用多命令一起执行,就是多个机器的执行时间要差不多一直,因为zookeeper对时间的要求性很高和各种问题
# zkServer.sh status    # 可以在各节点查看自己的角色是leader还是follower
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
### hive
{% endnote %}
{% endwow %}

#### Mariadb
{% note default orange simple %}这里为了方便直接安装mariadb作为MySQL使用,CentOS7.x和CentOS6.x使用方法不同(为了朋友写了CentOS6的，泪目了),使用前提网络要能访问外网{% endnote %}

{% tabs Mariadb %}
<!-- tab CentOS 7.x -->
{% tip sync %}CentOS 7.x{% endtip %}
```shell
[root@master ~]# yum install -y mariadb mariadb-server
[root@master ~]# systemctl enable mariadb && systemctl start mariadb
[root@master ~]# mysqladmin password abcd1234
[root@master ~]# mysql -uroot -pabcd1234 -e "create user 'root'@'%' identified by 'abcd1234';" -e "grant all privileges on *.* to 'root'@'%';"
[root@master ~]# mysql_secure_installation
按顺序输入abcd1234,n,y,n,y,y
```
<!-- endtab -->

<!-- tab CentOS 6.x -->
{% tip sync %}CentOS 6.x{% endtip %}
```shell
[root@master ~]# mkdir /etc/yum.repos.d/bak
[root@master ~]# mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
[root@master ~]# wget -O /etc/yum.repos.d/CentOS-Base.repo https://cdn1.tianli0.top/gh/linjiangyu2/halo/repo/CentOS-Base.repo && yum install -y epel-release
[root@master ~]# vim /etc/yum.repos.d/mariadb.repo
[mariadb]
name=MariaDB
baseurl=https://mirrors.aliyun.com/mariadb/yum/10.4/centos6-amd64
enabled=1
gpgkey=https://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
[root@master ~]# yum install -y mysql mysql-devel mysql-server
[root@master ~]# service mysql start && chkconfig --add mysql && chkconfig mysql on
[root@master ~]# mysqladmin password abcd1234
[root@master ~]# mysql -uroot -pabcd1234 -e "create user 'root'@'%' identified by 'abcd1234';" -e "grant all privileges on *.* to 'root'@'%';"
[root@master ~]# mysql_secure_installation
按顺序输入abcd1234,n,y,n,y,y
```
<!-- endtab -->
{% endtabs %}

{% folding cyan open, 这里使用的二进制包 %}

{% link apache-hive-3.1.2-bin.tar.gz,https://alist.linjiangyu.com/d/Linux/apache-hive-3.1.2-bin.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}

{% note default orange simple %} 把二进制包上传到master机器的opt目录下{% endnote %}

#### hive配置

```shell
[root@master ~]# cd /opt
[root@master opt]# tar xf apache-hive-3.1.2-bin.tar.gz
[root@master opt]# mv apache-hive-3.1.2-bin hive
[root@master opt]# cd hive/conf
[root@master conf]# cp -a hive-env.sh.template hive-env.sh
[root@master conf]# vim hive-env.sh
在最前面添加,这里对应好自己的目录
export JAVA_HOME=/usr/local/jdk
export HADOOP_HOME=/opt/hadoop285
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HADOOP_HEAPSIZE=1024
export HIVE_HOME=/opt/hive
export HIVE_CONF_DIR=${HIVE_HOME}/conf
export HIVE_AUX_JARS_PATH=${HIVE_HOME}/lib
```
```xml
[root@master conf]# vim hive-site.xml	// 以下对应注释更改自己的配置
<configuration>
        <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <!--这里对应填入自己主节点机器在hosts文件解析的域名，我是master，运行错误的话应该是你哪里的设置有问题就换成IP地址,后面对应的也就都换成IP地址-->
        <value>jdbc:mysql://master:3306/hive?createDatabaseIfNotExist=true</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionDriverName</name>
                <value>com.mysql.jdbc.Driver</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionUserName</name>
                <!--MySQL登陆用户-->
                <value>root</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionPassword</name>
                <!--用户密码-->
                <value>abcd1234</value>
        </property>
        <property>
                 <name>hive.server2.thrift.port</name>
                <value>10000</value>
        </property>
        <property>
                <name>hive.server2.thrift.bind.host</name>
                <!--这里对应解析第二台的hosts文件解析的域名-->
                <value>node1</value>
        </property>
        <property>
                 <name>hive.server3.thrift.port</name>
                <value>10000</value>
        </property>
        <property>
                <name>hive.server3.thrift.bind.host</name>
                <!--这里对应解析第三台的hosts文件解析的域名-->
                <value>node2</value>
        </property>
</configuration>
```
```shell
[root@master conf]# cp hive-log4j2.properties.template hive-log4j2.properties
[root@master conf]# vim hive-log4j2.properties
把INFO全部更改为ERROR
[root@master conf]# vim /etc/profile
export HIVE_HOME=/opt/hive
export PATH=${HIVE_HOME}/bin:$PATH
[root@master conf]# source /etc/profile
```

{% note default orange simple %}上传连接MySQL需要的jar包{% endnote %}

{% folding cyan open, mysql-connector-java-8.0.17.jar %}

{% link mysql-connector-java-8.0.17.jar,https://alist.linjiangyu.com/d/Linux/mysql-connector-java-8.0.17.jar,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

{% endfolding %}

```shell
[root@master ~]# mv  mysql-connector-java-8.0.17.jar /opt/hive/lib/
[root@master ~]# cd /opt/hive/bin
[root@master bin]# ./schematool -initSchema -dbType mysql	// 初始化
[root@master ~]# mysql -uroot -pabcd1234
mysql> show tables from hive;		// 有数据则初始化成功
```
#### 连接操作测试
{% note default orange simple %}hive的启动需要先启动hadoop和spark服务{% endnote %}

```shell
[root@master]# start-all.sh && spark-start.sh
# 把服务放在不同节点测试连接数据库操作
[root@master]# scp -r /opt/hive root@node1:/opt/
[root@master]# scp -r /opt/hive root@node2:/opt/
[root@master]# scp /etc/profile root@node1:/etc/
[root@master]# scp /etc/profile root@node2:/etc/
# 然后在各节点上使用命令
# source /etc/profile
# 回到master机器操作
[root@master]# hiveserver2
# 重开终端开启一个可被另外节点连接的服务终端
[root@master ~]# hive --service metastore
# 这里使用node1来连接,可能要等待久点才能起10000端口
[root@node1]# beeline		# 依次自己尝试
beeline> !connect jdbc:hive2://master:10000
Connecting to jdbc:hive2://master:10000
Enter username for jdbc:hive2://master:10000: root
Enter password for jdbc:hive2://master:10000: ***
Connected to: Apache Hive (version 3.1.2)
Driver: Hive JDBC (version 2.3.9)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://master:10000> show databases;
+----------------+
| database_name  |
+----------------+
| default        |
+----------------+
1 row selected (1.442 seconds)
```
#### 表创建测试
{% note default orange simple %}在master机器上准备一下用到的txt文件,上传到hdfs文件系统{% endnote %}
```shell
[master@root ~]# vim t.txt
1,linjiangyu,20
2,lintian,20
3,k,20
[master@root ~]# hdfs dfs -mkdir /t
[master@root ~]# hdfs dfs -put ./t.txt /t/
```
{% note default orange simple %}回到node1{% endnote %}
```shell
0: jdbc:hive2://master:10000> create database k ;
No rows affected (0.267 seconds)

0: jdbc:hive2://master:10000> use k;
No rows affected (0.078 seconds)

0: jdbc:hive2://master:10000> create table k_user(kid int,kname string,kage int) row format delimited fields terminated by ',' location '/t';
No rows affected (0.558 seconds)

0: jdbc:hive2://master:10000> show tables;
+-----------+
| tab_name  |
+-----------+
| k_user    |
+-----------+
1 row selected (0.114 seconds)

0: jdbc:hive2://master:10000> select * from k_user;
+-------------+---------------+--------------+
| k_user.kid  | k_user.kname  | k_user.kage  |
+-------------+---------------+--------------+
| 1           | linjiangyu    | 20           |
| 2           | lintian       | 20           |
| 3           | k             | 20           |
+-------------+---------------+--------------+
3 rows selected (3.141 seconds)
```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
