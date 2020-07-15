# 项目说明  
项目用于记录各类应用或中间件服务配置信息  
## 目录配置  
### 注: 
``` 
项目中使用的特殊符号与linux操作系统对应  
符号"～" 对应 用户家目录  
如:~/data/docker/ 指向 当前用户家目录下的/data/docker 目录
```

## 目录结构  
1. ### cerebro  
1. ### docker  
   1. docker-compose配置文件版本说明
      1. version "3" 添加command 多命令行支持[refer to](https://docs.docker.com/ee/)
         ```
         command:
            - /bin/bash
            - -c
            - |
              cd ~/tomcat/bin/
              startup.sh
         ```
1. ### elk
   [冷热分离配置](https://blog.csdn.net/weixin_34361881/article/details/86131416?utm_medium=distribute.pc_relevant.none-task-blog-OPENSEARCH-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-OPENSEARCH-1.nonecase)
1. ### git
1. ### gitlib
1. ### haproxy-keepalived
1. ### java
1. ### jenkins
1. ### k8s
1. ### kafka
1. ### linux 
1. ### loki
1. ### mongo
1. ### mysql
1. ### nexus
1. ### nginx
1. ### redis
1. ### rest
1. ### rocketMq
    1. [docker版本配置](https://github.com/apache/rocketmq-docker)
1. ### zk
 

