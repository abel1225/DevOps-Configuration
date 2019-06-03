FROM logstash:6.7.0

ADD mysql-connector-java-5.1.46.jar /usr/share/logstash/config/

#安装input插件
RUN logstash-plugin install logstash-input-jdbc
#安装output插件
RUN logstash-plugin install logstash-output-elasticsearch
#容器启动时执行的命令.(CMD 能够被 docker run 后面跟的命令行参数替换)
CMD ["-f", "/usr/share/logstash/config/logstash.conf"]
