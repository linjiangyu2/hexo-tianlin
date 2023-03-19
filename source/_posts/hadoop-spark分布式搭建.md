---
title: hadoop+spark分布式搭建
description: hadoop+spark分布式搭建
categories:
  - 服务集群
comment: true
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/hdsp.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/hdsp.jpg'
businesscard: true
abbrlink: 24c5d7d3
date: 2022-09-01 12:07:31
updated: 2022-09-02 09:07:55
tags:
---
# hadoop+spark分布式集群部署

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
1.环境准备
{% endnote %}
{% endwow %}

{% note default orange simple %} 环境的准备基于我写的初始化脚本,自用7.x系列的CentOS,老版本的就支持CentOS/Redhat6,7,8但是有点不完善，需要可以邮箱或者博客留言。{% endnote %}

|           os\ip           | hostname |                     block                      |
| :-----------------------: | :------: | :--------------------------------------------: |
| centos7.9 192.168.222.226 |  master  | rsmanager,datanode,namenode.snamenode,nmanager |
| centos7.9 192.168.222.227 |  node1   |           snamenode,nmnager,datanode           |
| centos7.9 192.168.222.228 |  node2   |             datanode,nmanager              |
```
# git clone https://github.com/linjiangyu2/K.git   //可能会拉不下来，多拉几次就下来了，因为托管代码的服务器是国外的
# cd K
# cat README.md  //不会使用的要看一下这个文件，了解脚本需要输入的配置
# ./ksh  //依次输入你自己的配置，第一次使用这个脚本一定要看README.md文件
# 如果需要有时候改IP地址图方便的话，直接把ksh这个二进制的脚本放在/usr/bin下，便可以在全局执行了
# mv ksh /usr/bin/ksh
使用ksh初始化后，开始配置
```
{% note default orange simple %} 对应自己的IP地址，最好/etc/hosts的解析名和我一致，不然下面的配置文件需要自己对应自己的解析名修改{% endnote %}
```
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
[master]# cd /usr/lib64
[master]# ln -s libcrypto.so.1.0.2k libcrypto.so
```

{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
2.搭建
{% endnote %}
{% endwow %}

####  上传jdk和hadoop的tar包
{% note default orange simple %} 这里使用的二进制包{% endnote %}

{% link hadoop-2.8.5.tar.gz,https://alist.linjiangyu.com/d/Linux/hadoop-2.8.5.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}
{% link jdk-8u212-linux-x64.tar.gz,https://alist.linjiangyu.com/d/Linux/jdk-8u212-linux-x64.tar.gz,https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg %}

```
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
```
# cd /opt/hadoop285/etc/hadoop
# vim hadoop-env.sh  //修改文件里面的export JAVA_HOME=${JAVA_HOME}为
export JAVA_HOME=/usr/local/jdk
# vim yarn-env.sh //修改前面有注释的export JAVA_HOME为
export JAVA_HOME=/usr/local/jdk
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
</configuration>
```

```
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

```
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

```
# cp mapred-site.xml.template mapred-site.xml
# vim mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

```
# vim slaves
master
node1
node2
```

{% note default orange simple %} 然后在master节点把配置发到各个节点{% endnote %}

```
[master]# for i in node{1..2};do rsync -av /usr/local/jdk root@$i:/usr/local/;done
# for i in node{1..2};do rsync -av /opt/hadoop285 root@$i:/opt/;done
# for i in node{1..2};do rsync -av /etc/profile root@$i:/etc/profile;done
然后到各个节点
[node1,2]# source /etc/profile
```

{% note default orange simple %} 在node1,2上操作，最后在master操作{% endnote %}

```
# hdfs namenode -format   //初始化
# ls -d /opt/data   //此文件夹产生就是初始化成功
```
{% note default orange simple %} 在master上操作{% endnote %}

```
[root@ master]# start-all.sh
```
{% note default orange simple %} 最后可以在各个节点使用jps命令查看各自的部件{% endnote %}

```
[root@ xxx]# jps
```
{% note default orange simple %} 当然web界面也可以访问的，浏览器访问192.168.222.226:8088和192.168.222.226:50070(对应自己IP地址){% endnote %}

{% note default orange simple %} 来尝试运行一下第一个hadoop分布式任务吧{% endnote %}

```
[root@ master]# hdfs dfs -put /etc/passwd /t1
[root@ master]# hadoop jar /opt/hadoop285/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.5.jar wordcount /t1 /output/00
[root@ master]# hdfs dfs -ls /output/00  //查看运行后的结果文件,运行后的数据在part-r-00000
```
{% note default orange simple %} 下面开始搭建分布式spark，这里使用的是spark的3.3.0版本{% endnote %}
{% note default orange simple %} [spark官网下载软件包](https://dlcdn.apache.org/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz){% endnote %}
```
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
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
