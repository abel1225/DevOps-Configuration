#!/bin/bash

#定义数据库目录和数据目录

mysqldir=/usr/local/mysql

datadir=$mysqldir/binlog

#定义用于备份数据库的用户名和密码

user=root

userpwd=123456

#定义备份目录

databackupdir=/mysqlbak

logbackupdir=$databackupdir/logs

#定义邮件正文文件

emailfile=$databackupdir/email.txt

#定义邮件地址

email=www@163.com

#定义备份日志文件

logfile=$databackupdir/mysqlbackup.log

#DATE=`date +%Y%m%d`

echo "" > $emailfile

echo $( date +"%Y-%m-%d %H:%M:%S" ) >> $emailfile

#刷新日志，使数据库使用新的二进制日志文件

/usr/bin/mysqladmin -u$user -p$userpwd flush-logs

cd $datadir

#得到二进制日志列表

filelist=`cat mysql_binlog.index`

icounter=0

for file in $filelist

do

    #需要注意的是符号和两个操作项之间的空格毕不可少，下面也是一样

  icounter=`expr $icounter + 1`

done

nextnum=0

ifile=0

for file in $filelist

do

binlogname=$file

nextnum=`expr $nextnum + 1`

#跳过最后一个二进制日志 （数据库当前使用的二进制日志文件）

if [ $nextnum -eq $icounter ];then

   echo "Skip lastest!" > /dev/null

else

   dest=$logbackupdir/$binlogname

#跳过已经备份的二进制日志文件

if [ -e $dest ];then

   echo "Skip exist $binlogname!" > /dev/null

else

#备份日志文件到备份目录

cp $binlogname $logbackupdir

if [ "$?" == 0 ];then

ifile=`expr $ifile + 1`

echo "$binlogname Backup Success!" >> $emailfile

   	 fi

     fi

fi

done

if [ $ifile -eq 0 ];then

   echo "No Binlog Backup!" >> $emailfile

else

   echo "Backup $ifile File(s)." >> $emailfile

   echo "Backup MySQL Binlog OK!" >> $emailfile

fi

#写日志文件

echo "-------------------------------------------------" >> $logfile

cat $emailfile >> $logfile

#发送邮件通知

cat $emailfile| mail -s "Mysql Backup" $email

