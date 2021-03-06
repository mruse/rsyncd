#!/bin/bash

# @author: me@mruse.cn
# @create: 2015.5.11
# @update: 2015.5.23

# ############################################################################
# start:
#   /usr/local/sersync2/sersync2 -n 4 -r -d -o /usr/local/sersync2/confxml.xml
# stop(kill): 
#   ps aux | grep sersync | awk '{print $2}' | xargs kill -9
# ############################################################################

# Define
htdocs="/path/to/webroot"
rsyncd_addr="192.168.0.2"
rsyncd_mod="cmstop"

## 下载Sersync @todo: url
wget #Sersync# -P /usr/local/src/

## 解压到 /usr/local/sersync2
tar xvf /usr/local/src/sersync2.5_64bit_binary_stable_final.tar.gz -C /usr/local/
mv /usr/local/GNU-Linux-x86/ /usr/local/sersync2

## 修改配置文件 @todo: path, ip
# 监控目录：<localpath watch="/opt/tongbu"> 
# 远程配置：<remote ip="127.0.0.1" name="rsync-model-name"/> 
sed -i 's#/opt/tongbu#'$htdocs'#' /usr/local/sersync2/confxml.xml
sed -i 's#127.0.0.1#'$rsyncd_addr'#' /usr/local/sersync2/confxml.xml
sed -i 's#tongbu1#'$rsyncd_mod'#' /usr/local/sersync2/confxml.xml

## 启动sersync, 创建,删除文件测试，看是否可以同步
/usr/local/sersync2/sersync2 -n 4 -r -d -o /usr/local/sersync2/confxml.xml
mkdir -p $htdocs/test/
touch $htdocs/test/{111,222,333}
touch $htdocs/test/$(date +%F_%T)
rm -rf $htdocs/test/222

## 启动sersync监控推送，加入开机启动
grep sersync /etc/rc.local||echo '/usr/local/sersync2/sersync2 -n 4 -r -d -o /usr/local/sersync2/confxml.xml' >> /etc/rc.local

## 创建启动脚本
wget https://raw.githubusercontent.com/mruse/rsyncd/master/sersync -P /etc/init.d/
chmod +x /etc/init.d/sersync
