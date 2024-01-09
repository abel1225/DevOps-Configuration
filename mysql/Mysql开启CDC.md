## Mysql开启CDC
### CDC（change data capture）,即变化数据捕捉，是数据库备份的一种方式，常用于大量数据的备份工作。分为侵入式和非侵入式的备份方法。
### 侵入式有基于触发器备份，基于时间戳备份，基于快照备份，非侵入式的备份方式是基于日志的备份
### Mysql 基于日志的CDC就是要开启mysql binary log;
- 修改my.cnf文件
```shell
   server_id=1  #（具体值不限，唯一即可）
   log_bin=mysql-bin
   binlog_format=ROW # 
   expire_logs_days=30
```
- 重启mysql服务
```shell
service mysqld restart
```

- 以root账户登录mysql数据库查看是否开启成功
```shell
show variables like 'log_bin' # 查询变量log_bin的值是否为“ON”
```

- 创建用户并赋予权限
```sql
   CREATE USER '[username]'@'%' IDENTIFIED BY '[password]';
   GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '[username]'@'%';
   FLUSH PRIVILEGES;
```