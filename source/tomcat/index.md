---
title: tomcat
date: 2023-01-29 16:00:00
comments: false
businesscard: true
url: /tomcat
type: "unit"
---
```powershell
# yum install apr apr-devel apr-utils openssl-devel
# tar xf tomcat-native-1.2.23-src.tar.gz 
# cd tomcat-native-1.2.23-src/native/
# ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=/usr/local/jdk --prefix=/usr/local/tomcat
# make && make install
```

{% note default simple %} 将jdk和tomcat写入环境变量{% endnote %}

```powershell
# vim /etc/profile
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=/usr/local/jdk/jre
export TOMCAT_HOME=/usr/local/tomcat
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH
```

{% note default simple %} 可以自己写一个小脚本{% endnote %}

```powershell
# vim /etc/init.d/tomcat
#!/bin/bash
#chkconfig: 2345 85 15
#description: By K <linjiangyu0702@qq.com>
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
function state() {
    netstat -tnlp | grep 8005 &> /dev/null
    if [ $? -ne 0 ];then
        let nu++
        if [ $nu -eq 1 ];then
            echo -e "\033[33mwait check listen 8005 listen health...\033[0m"
        fi
        if [[ $nu -ge 1 && $nu -lt 10  ]];then
            sleep 1
            state
        else
            echo -e "\033[31mbind listen 8005 not found\033[0m"
            exit 1
        fi
    fi
}
case $1 in
start)
    /usr/local/tomcat/bin/startup.sh 
    ;;
restart)
#    netstat -tnlp | grep 8005 &> /dev/null
    nu=0
    state
#    while [ $? -ne 0 ]
#    do
#        let nu++
#       if [ $nu -eq 1 ];then
#           echo -e "\033[33mwait check server health\033[0m"
#        fi
#        sleep 1
#        netstat -tnlp | grep 8005 &> /dev/null
#    done
    /usr/local/tomcat/bin/shutdown.sh &> /dev/null
    [ $? -eq 0 ] && /usr/local/tomcat/bin/startup.sh | tail -1 || echo -e "\033[31m$(basename $0) start is failed\033[0m"
    ;;
stop)
    nu=0
    state
    /usr/local/tomcat/bin/shutdown.sh
    kill $(ps aux | grep tomcat | grep -v grep | awk '{ print $2 }')
    ;;
status)    
    /usr/local/tomcat/bin/configtest.sh
    ;;
*)
    echo -e "\033[31mUsage: $(basename $0) (start|stop|status)\033[0m"
    ;;
esac
<!--这里要吐槽一下java的程序运行的是真的慢，服务刚启动的话8005的套接字端口不会那么快就启用，而关闭服务的时候是要使用到8005端口shutdown的，所以应该把restart服务加上一段时间-->

# chmod +x /etc/init.d/tomcat
# vim /usr/local/tomcat/bin/catalina.sh	# 把环境变量写入相应需要的文件中(tomcat的变量这里没有引用系统环境变量,所以要自己再写上)
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=/usr/local/jdk/jre
# chkconfig --add tomcat
# chkconfig tomcat on
# service tomcat start
```
- unit
```nginx
# cat > /usr/lib/systemd/system/tomcat.service <<END
# /usr/lib/systemd/system/tomcat.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/

[Unit]
Documentation=man:systemd-sysv-generator(8)
SourcePath=/etc/rc.d/init.d/tomcat
Description=SYSV: By K <linjiangyu0702@qq.com>
Before=runlevel2.target
Before=runlevel3.target
Before=runlevel4.target
Before=runlevel5.target
Before=shutdown.target
After=network-online.target
After=network.service
Conflicts=shutdown.target

[Service]
Type=forking
Restart=no
TimeoutSec=5min
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=yes
ExecStart=/etc/rc.d/init.d/tomcat start
ExecStop=/etc/rc.d/init.d/tomcat stop
END
# systemctl daemon-reload
# systemctl enable --now tomcat
```
- service(未完全测试)
```nginx
# cat > /etc/init.d/tomcat <<END
#!/bin/bash
#chkconfig: 2345 85 15
#description: By K <linjiangyu0702@qq.com>
#author: linjiangyu
#cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
function state() {
    netstat -tnlp | grep 8005 &> /dev/null
    if [ $? -ne 0 ];then
        let nu++
        if [ $nu -eq 1 ];then
            echo -e "\033[33mwait check listen 8005 listen health...\033[0m"
        fi
        if [[ $nu -ge 1 && $nu -lt 10  ]];then
            sleep 1
            state
        else
            echo -e "\033[31mbind listen 8005 not found\033[0m"
            exit 1
        fi
    fi
}
case $1 in
start)
    /usr/local/tomcat/bin/startup.sh 
    ;;
restart)
#    netstat -tnlp | grep 8005 &> /dev/null
    nu=0
    state
#    while [ $? -ne 0 ]
#    do
#        let nu++
#       if [ $nu -eq 1 ];then
#           echo -e "\033[33mwait check server health\033[0m"
#        fi
#        sleep 1
#        netstat -tnlp | grep 8005 &> /dev/null
#    done
    /usr/local/tomcat/bin/shutdown.sh &> /dev/null
    [ $? -eq 0 ] && /usr/local/tomcat/bin/startup.sh | tail -1 || echo -e "\033[31m$(basename $0) start is failed\033[0m"
    ;;
stop)
    nu=0
    state
    /usr/local/tomcat/bin/shutdown.sh
    ;;
status)    
    /usr/local/tomcat/bin/configtest.sh
    ;;
*)
    echo -e "\033[31mUsage: $(basename $0) (start|stop|status)\033[0m"
    ;;
esac
END

# chmod u+x /etc/init.d/tomcat
```
- Unit
```nginx
# /usr/lib/systemd/system/tomcat.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Documentation=https://linjiangyu.com/tomcat
SourcePath=/etc/rc.d/init.d/tomcat
Description=SYSV: By K <linjiangyu0702@qq.com>
Before=runlevel2.target
Before=runlevel3.target
Before=runlevel4.target
Before=runlevel5.target
Before=shutdown.target
After=network-online.target
After=network.service
Conflicts=shutdown.target

[Service]
Type=forking
Restart=no
TimeoutSec=5min
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=yes
ExecStart=/etc/rc.d/init.d/tomcat start
ExecStop=/etc/rc.d/init.d/tomcat stop

[Install]
WantedBy=multi-user.target
```
