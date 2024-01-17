## Mysql开启CDC
```txt
CDC（change data capture）,即变化数据捕捉，是数据库备份的一种方式，常用于大量数据的备份工作。分为侵入式和非侵入式的备份方法。
侵入式有基于触发器备份，基于时间戳备份，基于快照备份，非侵入式的备份方式是基于日志的备份
Mysql 基于日志的CDC就是要开启mysql binary log;
```

- 修改my.cnf文件
```shell
   server_id=1  #（具体值不限，唯一即可）
   log_bin=mysql-bin
   binlog_format=ROW # CDC必要
   expire_logs_days=30
```
```txt
设置binlog_format=ROW的主要原因有以下几点：

1.更精确的数据变更记录:
ROW格式记录的是每一行数据的变更，而不是SQL语句。这样可以更准确地捕捉每一行数据的插入、更新和删除操作，无论是通过直接SQL语句、存储过程还是触发器进行的变更。
2.避免不确定性:
使用ROW格式可以避免STATEMENT格式中由于触发器、存储过程等引起的不确定性。STATEMENT格式记录的是SQL语句，而某些操作（例如使用RAND()函数）可能在主服务器和从服务器上产生不同的结果，导致在从服务器上执行时产生不一致的数据。
3.支持主从复制的一致性:
在主从复制中，如果主服务器和从服务器上的数据格式不一致，可能会导致复制错误。使用ROW格式可以确保主从服务器上的数据一致性，因为它记录的是实际数据的变更。
4.易于解析和处理:
ROW格式的二进制日志相对容易解析，可以更轻松地在CDC应用中进行处理。相比于STATEMENT格式，它不需要解析SQL语句，而是直接提供了变更的行数据，使得处理更加直观和可靠。
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