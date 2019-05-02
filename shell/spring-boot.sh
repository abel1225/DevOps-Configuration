#!/bin/bash
JAVA_HOME="/usr/java/jdk1.8.0_161"

RUNNING_USER=ec2-user

APP_HOME=/home/ec2-user/wechat/apps/aegeanminiprogram/server/

SERVER_NAME=aegeanMiniprogram.jar

JAVA_OPTS="-ms16m -mx64m -Xmn32m -Djava.awt.headless=true"

psid=0

checkpid() {
   javaps=`$JAVA_HOME/bin/jps -l | grep $SERVER_NAME`
 
   if [ -n "$javaps" ]; then
      psid=`echo $javaps | awk '{print $1}'`
   else
      psid=0
   fi
}
 

start() {
   checkpid
 
   if [ $psid -ne 0 ]; then
      echo "================================"
      echo "warn: $SERVER_NAME already started! (pid=$psid)"
      echo "================================"
   else
      echo -n "Starting $SERVER_NAME ..."
      nohup java -jar $APP_HOME$SERVER_NAME --spring.profiles.active=default > /home/ec2-user/wechat/apps/logs/aegean_miniprogram_server.log 2>&1 &
      checkpid
      if [ $psid -ne 0 ]; then
         echo "(pid=$psid) [OK]"
      else
         echo "[Failed]"
      fi
   fi
}
 

stop() {
   checkpid
 
   if [ $psid -ne 0 ]; then
      echo -n "Stopping $SERVER_NAME ...(pid=$psid) "
      kill -9 $psid
      if [ $? -eq 0 ]; then
         echo "[OK]"
      else
         echo "[Failed]"
      fi
 
      checkpid
      if [ $psid -ne 0 ]; then
         stop
      fi
   else
      echo "================================"
      echo "warn: $SERVER_NAME is not running"
      echo "================================"
   fi
}
 

status() {
   checkpid
 
   if [ $psid -ne 0 ];  then
      echo "$SERVER_NAME is running! (pid=$psid)"
   else
      echo "$SERVER_NAME is not running"
   fi
}
 

info() {
   echo "System Information:"
   echo "****************************"
   echo `head -n 1 /etc/issue`
   echo `uname -a`
   echo
   echo "JAVA_HOME=$JAVA_HOME"
   echo `$JAVA_HOME/bin/java -version`
   echo
   echo "APP_HOME=$APP_HOME"
   echo "SERVER_NAME=$SERVER_NAME"
   echo "****************************"
}

case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'restart')
     stop
     start
     ;;
   'status')
     status
     ;;
   'info')
     info
     ;;
  *)
echo "Usage: $0 {start|stop|restart|status|info}"
exit 1
esac 
exit 0
