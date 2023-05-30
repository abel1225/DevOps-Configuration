#!/bin/bash
dbhost="dbhost"
username="username"
password="password"
port="port"
backdate=$(date "+%Y%m%d")
backupbaseDir="/data/binlog/bak/"
backupDir="$backupbaseDir$backdate"
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
#index=0
for binlog in $binlogs;
  do
  #index=`expr $index + 1`  # 如果是最后一个binlog，就不做备份
  #if [ "$index" == "$num" ];then
  #  echo "No need backup last binlog [$index]:"$binlog
  #else
  #  backuped=false
  #  for existlog in $existlogs;
  #    do
      # 备份的文件名和binlog文件名一致，说明已备份过
      #if [ "${existlog%.*}" == "$binlog" ];then
      #  backuped=true
      #  break
      #fi
      #done
      #if $backuped;then
      #  echo "No need backup $binlog cause it backuped"
      #else
      echo "Now backup binlog[$index]:$binlog"
      #解码后备份到backupDir路径下
      `mysqlbinlog -u$username -p$password -h$dbhost -P$port --read-from-remote-server -vv --base64-output=decode-rows $binlog > $backupDir/$binlog.log`
      #fi
  #fi
  done
#清理过期文件/目录
ReservedNum=3  #保留文件数
FileDir="$backupbaseDir"
date=$(date "+%Y%m%d-%H%M%S")

cd $FileDir   #进入备份目录
FileNum=$(ls -l | grep '^d' | wc -l)   #当前有几个文件夹，即几个备份

while(( $FileNum > $ReservedNum))
do
    OldFile=$(ls -rt | head -1)         #获取最旧的那个备份文件夹
    echo  $date "Delete File:"$OldFile
    rm -rf $FileDir/$OldFile
    let "FileNum--"
done