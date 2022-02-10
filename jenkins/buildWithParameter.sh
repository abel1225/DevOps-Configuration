## 参数化构建脚本
case $Status  in
  Deploy)
    echo "Status:$Status"
    path="${WORKSPACE}/bak/${BUILD_NUMBER}"      #创建每次要备份的目录
    if [ -d $path ];
    then
        echo "The files is already  exists "
    else
        mkdir -p  $path
    fi
    \cp -f ${WORKSPACE}/shuyue_corelayer/com.shuyue.finance-server/target/*.jar $path
    scp ${WORKSPACE}/shuyue_corelayer/com.shuyue.finance-server/target/finance-server.jar root@172.27.153.75:/data/java_server/
ssh root@172.27.153.75 'sh /data/java_server/inventoryfinance/server_start2.sh finance-server.jar'
    #将打包好的war包备份到相应目录,覆盖已存在的目标
    echo "Completing!"
    ;;
  Rollback)
      echo "Status:$Status"
      echo "Version:$Version"
      cd ${WORKSPACE}/bak/$Version            #进入备份目录
      \cp -f *.jar ${WORKSPACE}/shuyue_corelayer/com.shuyue.finance-server/target/
      scp ${WORKSPACE}/shuyue_corelayer/com.shuyue.finance-server/target/finance-server.jar root@172.27.153.75:/data/java_server/
      ssh root@172.27.153.75 'sh /data/java_server/inventoryfinance/server_start2.sh finance-server.jar'
      #将备份拷贝到程序打包目录中，并覆盖之前的war包
      ;;
  *)
  exit
      ;;
esac


## 备份文件清理脚本
ReservedNum=5  #保留文件数
FileDir=${WORKSPACE}/bak/
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
