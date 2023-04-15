---
title: php-fpm
date: 2023-01-29 16:00:00
comments: false
businesscard: true
url: /apache
type: "unit"
---
```nginx
# cat > /usr/lib/systemd/system/php-fpm.service <<END
# /usr/lib/systemd/system/php-fpm.service
[Unit]
Description=Unit PHP-FPM By Tianlin
Documentation=https://linjiangyu.com/php-fpm
After=network-online.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/php/var/run/php-fpm.pid
ExecStart=/usr/local/php/sbin/php-fpm -y /usr/local/php/etc/php-fpm.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
User=www
Group=www

[Install]
WantedBy=multi-user.target
END
```
- 或者是
```nginx
~]# cat > /usr/lib/systemd/system/php-fpm.service <<END
# /usr/lib/systemd/system/php-fpm.service
# author: linjiangyu
# cc: https://creativecommons.org/licenses/by-nc-sa/4.0/
[Unit]
Documentation=man:systemd-sysv-generator(8)
SourcePath=/etc/rc.d/init.d/php-fpm
Description=LSB: starts php-fpm
Before=runlevel2.target
Before=runlevel3.target
Before=runlevel4.target
Before=runlevel5.target
Before=shutdown.target
Before=runlevel5.target
Before=shutdown.target
After=remote-fs.target
After=network-online.target
After=network-online.target
Wants=network-online.target
Conflicts=shutdown.target

[Service]
Type=forking
Restart=no
TimeoutSec=5min
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=yes
ExecStart=/etc/rc.d/init.d/php-fpm start
ExecStop=/etc/rc.d/init.d/php-fpm stop
ExecReload=/etc/rc.d/init.d/php-fpm reload

[Install]
WantedBy=multi-user.target
END
```

```nginx
# cat > /etc/init.d/php-fpm <<END
#! /bin/sh

### BEGIN INIT INFO
# Provides:          php-fpm
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts php-fpm
# Description:       starts the PHP FastCGI Process Manager daemon
### END INIT INFO

prefix=/usr/local/php
exec_prefix=${prefix}

php_fpm_BIN=${exec_prefix}/sbin/php-fpm
php_fpm_CONF=${prefix}/etc/php-fpm.conf
php_fpm_PID=${prefix}/var/run/php-fpm.pid


php_opts="--fpm-config $php_fpm_CONF --pid $php_fpm_PID"


wait_for_pid () {
        try=0

        while test $try -lt 35 ; do

                case "$1" in
                        'created')
                        if [ -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;

                        'removed')
                        if [ ! -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;
                esac

                echo -n .
                try=`expr $try + 1`
                sleep 1

        done

}

case "$1" in
        start)
                echo -n "Starting php-fpm "

                $php_fpm_BIN --daemonize $php_opts

                if [ "$?" != 0 ] ; then
                        echo " failed"
                        exit 1
                fi

                wait_for_pid created $php_fpm_PID

                if [ -n "$try" ] ; then
                        echo " failed"
                        exit 1
                else
                        echo " done"
                fi
        ;;

        stop)
                echo -n "Gracefully shutting down php-fpm "

                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi

                kill -QUIT `cat $php_fpm_PID`

                wait_for_pid removed $php_fpm_PID

                if [ -n "$try" ] ; then
                        echo " failed. Use force-quit"
                        exit 1
                else
                        echo " done"
                fi
        ;;

        status)
                if [ ! -r $php_fpm_PID ] ; then
                        echo "php-fpm is stopped"
                        exit 0
                fi

                PID=`cat $php_fpm_PID`
                if ps -p $PID | grep -q $PID; then
                        echo "php-fpm (pid $PID) is running..."
                else
                        echo "php-fpm dead but pid file exists"
                fi
        ;;

        force-quit)
                echo -n "Terminating php-fpm "

                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi

                kill -TERM `cat $php_fpm_PID`

                wait_for_pid removed $php_fpm_PID

                if [ -n "$try" ] ; then
                        echo " failed"
                        exit 1
                else
                        echo " done"
                fi
        ;;

        restart)
                $0 stop
                $0 start
        ;;

        reload)

                echo -n "Reload service php-fpm "

                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi

                kill -USR2 `cat $php_fpm_PID`

                echo " done"
        ;;

        configtest)
                $php_fpm_BIN -t
        ;;

        *)
                echo "Usage: $0 {start|stop|force-quit|restart|reload|status|configtest}"
                exit 1
        ;;

esac
END
```
