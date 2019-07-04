#!/bin/bash
CONTAINERID=$1
FILE_LOCATION=$2
TARGET_LOCATION=$3

if [ ! -n "$CONTAINERID" ]; then 
  echo "please input CONTAINERID"
  exit 0
fi

CONTAINEREXISTS=0
containers=`docker ps -a|awk '{print $1}'`

for container in $containers
  do 
    if [ "$CONTAINERID" == "$container" ];then
      CONTAINEREXISTS=1
      echo "$container"
    fi
  done

if [ $CONTAINEREXISTS -eq 0 ];then
  echo "container $CONTAINERID not exists!"
  exit 0
fi

docker cp $FILE_LOCATION $CONTAINERID:$TARGET_LOCATION

result=`echo '$TARGET_LOCATION' | grep '/$'`
if [ ! -n "$result" ]; then
  TARGET_LOCATION=$TARGET_LOCATION"/"
fi

echo "TARGET_LOCATION $TARGET_LOCATION"

docker exec -it $CONTAINERID /bin/bash -c ".$TARGET_LOCATION../dubbo.sh restart"
