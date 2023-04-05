---
title: redis
date: 2022-11-06 00:00:00
comments: false
businesscard: true
url: /redis
type: "unit"
---
### redis.service
```mysql
# cat > /usr/lib/systemd/system/redis.service <<END
# /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis unit by Tianlin
Documentation=https://linjiangyu.com/redis
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target 

[Service]
Type=simple
PIDFile=/usr/local/redis/run/redis_6379.pid
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf --supervised systemd
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
END

或者是
~]# cat > /usr/lib/systemd/system/redis.service <<END
# /usr/lib/systemd/system/redis.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Redis unit by linjiangyu
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=fork
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf --supervised systemd
ExecReload=/bin/kill -s HUP
ExecStop=/bin/kill -s QUIT
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
END

或者是

# cat > /usr/lib/systemd/system/redis.service <<END
# /usr/lib/systemd/system/redis.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit redis by linjiangyu
Documentation=https://linjiangyu.com/redis
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf --supervised systemd
ExecReload=/bin/kill -s HUP
ExecStop=/bin/kill -s QUIT
User=redis

[Install]
WantedBy=multi-user.target
END
```
### redis-cluster.service
```mysql
~]#  cat > /usr/lib/systemd/system/redis-slave.service <<END
# /usr/lib/systemd/system/redis-slave.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]                                  
Description=Redis persistent key-value database
After=network.target    
After=network-online.target
Wants=network-online.target

[Service]                               
Type=fork
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis-slave.conf  -
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
User=redis                      
Group=redis                     
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
END
```
### redis-sentinel.service
```mysql
~]# cat > /usr/lib/systemd/system/redis-sentinel.service <<END
# /usr/lib/systemd/system/redis-sentinel.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Description=Unit sentinel by linjiangyu
Documentation=https://linjiangyu.com/redis
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=fork
ExecStart=/usr/local/redis/bin/redis-sentinel /usr/local/redis/conf/sentinel.conf --supervised systemd
ExecReload=/bin/kill -s QUP $MAINPID
ExecStop=/bin/kill -s HUIT $MAINPID
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
END
```
