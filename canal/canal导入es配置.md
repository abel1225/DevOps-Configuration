## 同步表customer的配置样例
- 同步之前需要先创建号索引
```shell
curl -X PUT "http://[esserver]:9200/customer/" -H 'Content-Type: application/json' -d'
{
    "settings" : {
    	"number_of_shards" : 3,
        "number_of_replicas" : 0
    },
    "mappings":{
       "search_data":{
	        "properties":{
                "id": {
                    "type": "long"
                },
                "username": {
                    "type": "text",
                    "fields":{
                        "keyword":{
                            "type":"keyword",
                            "ignore_above":256
                        }
                    },
                    "analyzer": "ik_max_word"
                },
                "mobile": {
                    "type": "text",
                    "fields":{
                        "keyword":{
                            "type":"keyword",
                            "ignore_above":256
                        }
                    },
                    "analyzer": "ik_max_word"
                },
                "sex": {
                    "type": "keyword"
                },
                "type": {
                    "type": "text",
                    "fields":{
                        "keyword":{
                            "type":"keyword",
                            "ignore_above":256
                        }
                    },
                    "analyzer": "ik_max_word"
                },
                "createTime": {
                    "type": "date"
                },
                "updateTime": {
                    "type": "date"
                },
                "company": {
                    "type": "text",
                    "fields":{
                        "keyword":{
                            "type":"keyword",
                            "ignore_above":256
                        }
                    },
                    "analyzer": "ik_max_word"
                }
	        }
       }
    }
}'

```
- 安装[canal](https://github.com/alibaba/canal/wiki/Sync-ES)

- 配置样例
> canal.adapter-xxx\conf\application.yml
```yaml
server:
  port: 8081
spring:
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
    default-property-inclusion: non_null

canal.conf:
  mode: rocketMQ # kafka rocketMQ
  mqServers: 192.168.28.130:9876 #or rocketmq
  flatMessage: true
  batchSize: 500
  syncBatchSize: 1000
  retries: 0
  timeout:
  accessKey:
  secretKey:
  srcDataSources:
    defaultDS:
      url: jdbc:mysql://192.168.28.130:3306/user-center?useUnicode=true
      username: canal
      password: canal
  canalAdapters:
  - instance: canal-sys-user # canal instance Name or mq topic name
    groups:
    - groupId: g1
      outerAdapters:
      - name: logger
      - name: es
        hosts: 192.168.28.130:9300
        properties:
          cluster.name: my-es
```
> mode：消费的类型有3种选择tcp、kafka和rocketMQ
> 
> mqServers: mq的地址
> 
> defaultDS：配置源数据库的地址
> 
> instance：配置mq的topic名称
> 
> es：配置es的地址和集群名

> canal.adapter-xxx\conf\es\sys_user.yml
```yaml
dataSourceKey: defaultDS
destination: canal-customer
groupId: g1
esMapping:
  _index: customer
  _type: search_data
  _id: id
  upsert: true
  sql: "select id, username, nickname, mobile ,sex, type, create_time createTime, update_time updateTime, company 
        from customer"
  etlCondition: "where update_time >= '{0}'"
  commitBatch: 3000
```

> dataSourceKey：配置application.yml中源数据库的key
> 
> destination：配置mq的topic名称
> 
> _index：插入es中的索引名
> 
> _type：插入es中mappings的type属性
> 
> _id：配置id字段
> 
> upsert：配置插入数据正常时写入，主键冲突时更新
> 
> sql：配置具体要同步es的数据
> 
> etlCondition：条件判断，通过更新日期实现增量同步

> 如果在搭建增量同步之前mysql数据库已经存在历史数据，就需要做初始化同步，全量同步可以使用Canal-Adapter的rest-api来实现
> 如下：
```shell
curl -X POST http://192.168.28.130:8081/etl/es/customer.yml
```
> ip为Canal-Adapter所在服务器ip
> 路径/es/sys_user.yml为conf目录下配置文件的路径，会自动忽略where条件进行全量同步 

