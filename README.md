# rsyncd
/usr/bin/rsyncd

### 安装 rsync

    yum --noplugins --nogpgcheck -y install rsync

### 创建 rsyncd 配置文件

    cat >> /etc/rsyncd.conf <<RSYNC
    # @start MrUse Rsyncd $(date +%F_%T)
    # @daemon:  /usr/bin/rsync --daemon --config=/etc/rsyncd.conf
    # @demo:
    #   rsync -arogvzP --delete --exclude=filter/* /path/to/webroot/* 192.168.0.1::mruse
    #   rsync -vzrtopg --delete --exclude /path/from/* /path/to/
    #   rsync -arogvzP --delete --exclude=data/* /path/to/webroot/* 192.168.0.1:/path/to/webroot
    
    ##########
    # Global #
    ##########
    uid = root
    gid = root
    port = 873
    lock file = /var/run/rsyncd.lock
    pid file = /var/run/rsyncd.pid
    log file = /var/log/rsyncd.log
    max connections = 36000
    #syslog facility = local5
    
    ###########
    # Modules #
    ###########
    [mruse]
    path = /path/to/webroot
    comment = this is comment
    list = false
    read only = no
    write only = yes
    use chroot = no
    ignore errors = yes
    hosts allow = 192.168.0.1,192.168.0.2
    hosts deny = *
    #auth users = 
    #secrets file =
    
    # @end MrUse Rsyncd $(date +%F_%T)
    RSYNC


### 修改配置文件
    模块名称: [mruse] 
    同步路径: path = /path/to/webroot 
    允许地址: hosts allow = 192.168.0.1,192.168.0.2

### 启动rsync守护进程，加入开机启动
    /usr/bin/rsync --daemon --config=/etc/rsyncd.conf
    grep '^/usr/bin/rsync' /etc/rc.local|| echo '/usr/bin/rsync --daemon --config=/etc/rsyncd.conf' >> /etc/rc.local

### 加入日志轮询，避免日志太大
    cat >> /etc/logrotate.d/rsync <<LOGROTATE
    /var/log/rsyncd.log {
            compress
            delaycompress
            missingok
            notifempty
            rotate 6
            create 0600 root root
    }
    LOGROTATE

### iptables开通873端口
    iptables --line-number -n -L
    iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp -s 192.168.0.1 --dport 873 -j ACCEPT
    iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp -s 192.168.0.2 --dport 873 -j ACCEPT
    /etc/init.d/iptables save

### 检查监听状态及iptables端口是否开启
    netstat -antp | grep LISTEN|grep 873
    iptables --line-number -n -L|grep 873

### 手动同步测试
    rsync -arogvzP --delete --exclude=filter/* /path/to/webroot/* 192.168.0.1::mruse

### 本地目录同步
    rsync -vzrtopg --delete --exclude /path/from/* /path/to/

### 通过ssh拷贝（不依赖rsyncd守护进程）
    rsync -arogvzP --delete --exclude=data/* /data/www/cmstop/* 192.168.0.1:/path/to/webroot

### 创建启动脚本
    vi /usr/bin/rsyncd 粘贴启动脚本内容
    chmod + /usr/bin/rsyncd

### 测试启动脚本
    /usr/bin/rsyncd {start|stop|restart|status}
