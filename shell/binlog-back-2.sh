#!/bin/bash
dbhost="localhost"
username="root"
password="root"
port="3306"
backupDir="/data/log/binlog"
binlogs=`mysql -h$dbhost -u$username -p$password -P$port -e 'show binary logs;' | awk '$1 ~ /mysql-bin.*/ {print $1}'`
num=0
for binlog in $binlogs;
  do  num=`expr $num + 1`
  echo "数据库当前的binlog:"$binlog
  done
# 此处获取到binlog的备份文件，过滤掉路径，筛选出文件名
existlogs=`ls -lh $backupDir/mysql-bin.* | awk '{print $9}' | awk -F'/' '{print $5}'`
for existlog in $existlogs;
  do
  echo "当前的备份有:"$existlog
  done
index=0
for binlog in $binlogs;
  do
  index=`expr $index + 1`  # 如果是最后一个binlog，就不做备份
  if [ "$index" == "$num" ];then
    echo "No need backup last binlog [$index]:"$binlog
  else
    backuped=false
    for existlog in $existlogs;
      do
      # 备份的文件名和binlog文件名一致，说明已备份过
      if [ "${existlog%.*}" == "$binlog" ];then
        backuped=true
        break
      fi
      done
      if $backuped;then
        echo "No need backup $binlog cause it backuped"
      else
        echo "Now backup binlog[$index]:$binlog"
      #解码后备份到backupDir路径下
      `mysqlbinlog -u$username -p$password -h$dbhost -P$port --read-from-remote-server -vv --base64-output=decode-rows $binlog > $backupDir/$binlog.log`
      fi
  fi
  done
