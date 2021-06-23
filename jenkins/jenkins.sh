#!/bin/bash
# 配置要启动关闭的脚本名
process_name="jenkins.war"
http_port=9191
#修改端口和JENKINS_HOME 当前是当前目录
export JENKINS_HOME=./home
# 添加启动命令
function start(){
    echo "start..."

    nohup java -jar $process_name --httpPort=$http_port 2>&1 &

    echo "start successful"
    return 0
}

# 添加停止命令
function stop(){
    echo "stop..."

    ps aux |grep $process_name |grep -v grep |awk '{print "kill -9 " $2}'|sh

    echo "stop successful"
    return 0
}

case $1 in
"start")
    start
    ;;
"stop")
    stop
    ;;
"restart")
    stop && start
    ;;
*)
    echo "请输入: start, stop, restart"
    ;;
esac
