# 项目说明  
> 项目用于记录各类应用或中间件服务配置信息  
## 目录配置
>项目中使用的特殊符号与linux操作系统对应  
符号"～" 对应 用户家目录  
如:~/data/docker/ 指向 当前用户家目录下的/data/docker 目录

## 目录结构  
1. ### cerebro  
2. ### docker  
   1. docker-compose配置文件版本说明
      1. version "3" 添加command 多命令行支持[docker ee](https://docs.docker.com/ee/)
         ```shell
         command:
            - /bin/bash
            - -c
            - |
              cd ~/tomcat/bin/
              startup.sh
         ```
3. ### elk
   [冷热分离配置](https://blog.csdn.net/weixin_34361881/article/details/86131416?utm_medium=distribute.pc_relevant.none-task-blog-OPENSEARCH-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-OPENSEARCH-1.nonecase)
4. ### git
5. ### gitlib
6. ### haproxy-keepalived
7. ### java
8. ### jenkins
9. ### k8s
10. ### kafka
11. ### linux 
12. ### loki
13. ### mongo
14. ### mysql
15. ### nexus
16. ### nginx
17. ### redis
18. ### rest
19. ### rocketMq
     1. [docker版本配置](https://github.com/apache/rocketmq-docker)
20. ### zk
 

