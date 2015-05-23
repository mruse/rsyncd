#!/bin/bash

# @author: me@mruse.cn
# @create: 2015-05-23
# @update: 2015-05-23

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH=$PATH

############ Define ############ 
rsyncd_mod="mruse"
rsyncd_path="/path/to/webroot"
rsyncd_comment="Comments for MrUse Project"
rsyncd_allows="192.168.0.1,192.168.0.2"

# Install rsync
yum --noplugins --nogpgcheck -y install rsync

# Create /etc/rsyncd.conf
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
comment = Comments for MrUse Project
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

# Modify config
sed -i 's#mruse#'$rsyncd_mod'#g' /etc/rsyncd.conf
sed -i 's#/path/to/webroot#'$rsyncd_path'#g' /etc/rsyncd.conf
sed -i 's#^comment.*#comment = '$rsyncd_comment'#g' /etc/rsyncd.conf
sed -i 's#192.168.0.1,192.168.0.2#'$rsyncd_allows'#g' /etc/rsyncd.conf

# Start & Bootup
/usr/bin/rsync --daemon --config=/etc/rsyncd.conf
grep '^/usr/bin/rsync' /etc/rc.local|| echo '/usr/bin/rsync --daemon --config=/etc/rsyncd.conf' >> /etc/rc.local

# Rotate /var/log/rsyncd.log
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
/etc/init.d/rsyslog restart

# Config Iptables 
line_number=$(iptables -n -L --line-number |grep ':22\|:80'|awk '{print $1}'| head -1)
#echo $line_number
iptables -I INPUT $line_number -p tcp -m state --state NEW -m tcp -s $rsyncd_allows --dport 873 -j ACCEPT
/etc/init.d/iptables save

# Shell for {start|stop}
wget https://raw.githubusercontent.com/mruse/rsyncd/master/rsyncd -P /etc/init.d/
chmod +x /etc/init.d/rsyncd
