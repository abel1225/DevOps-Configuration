在 Kubernetes 上部署 RocketMQ 集群通常涉及创建 StatefulSets、Services 以及配置持久化存储等。以下是一个基本的 RocketMQ 集群在 Kubernetes 上部署的操作流程，以及相关的命令样例。

创建命名空间
-
```shell
kubectl create namespace rocketmq
kubectl config set-context --current --namespace=rocketmq
```

创建 ConfigMap
-
- 创建 RocketMQ 的配置文件 ConfigMap，用于配置 NameServer 和 Broker。
```shell
kubectl create configmap rocketmq-config --from-file=config/namesrv.conf --from-file=config/broker.conf
```

创建 StatefulSet 和 Service for NameServer
-
- rocketmq-namesrv-statefulset.yaml

```yaml
# rocketmq-namesrv-statefulset.yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rocketmq-namesrv
spec:
    serviceName: rocketmq-namesrv
    replicas: 1
    selector:
        matchLabels:
          app: rocketmq-namesrv
    template:
        metadata:
          labels:
            app: rocketmq-namesrv
        spec:
            containers:
              - name: rocketmq-namesrv
                image: <your-rocketmq-image>
                command: ["sh", "-c", "bin/mqnamesrv"]
                ports:
                  - containerPort: 9876
                volumeMounts:
                  - name: rocketmq-config
                    mountPath: /opt/rocketmq-4.10.0/conf
    volumeClaimTemplates:
      - metadata:
          name: rocketmq-config
        spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 1Gi

---

apiVersion: v1
kind: Service
metadata:
  name: rocketmq-namesrv
spec:
  ports:
  - port: 9876
  selector:
    app: rocketmq-namesrv



```

```shell
kubectl apply -f rocketmq-namesrv-statefulset.yaml
```

创建 StatefulSet 和 Service for Broker
-
- rocketmq-broker-statefulset.yaml

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rocketmq-broker
spec:
    serviceName: rocketmq-broker
    replicas: 3 # 可根据需求调整副本数
    selector:
        matchLabels:
          app: rocketmq-broker
    template:
        metadata:
            labels:
              app: rocketmq-broker
        spec:
            containers:
                - name: rocketmq-broker
                  image: your-rocketmq-image
                  command: ["sh", "-c", "bin/mqbroker -c /opt/rocketmq-4.10.0/conf/broker.conf"]
                  ports:
                    - containerPort: 10911
                  volumeMounts:
                    - name: rocketmq-config
                      mountPath: /opt/rocketmq-4.10.0/conf
    volumeClaimTemplates:
      - metadata:
          name: rocketmq-config
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi

---

apiVersion: v1
kind: Service
metadata:
  name: rocketmq-broker
spec:
    ports:
    - port: 10911
    selector:
      app: rocketmq-broker
```

```shell
kubectl apply -f rocketmq-broker-statefulset.yaml
```

验证集群状态
- 
- 获取 NameServer 的 Pod 名称
```shell
namesrv_pod=$(kubectl get pods -l app=rocketmq-namesrv -o jsonpath='{.items[0].metadata.name}')
```

-  查看 NameServer 集群状态
```shell
kubectl exec -it $namesrv_pod -- bin/mqadmin clusterList -n localhost:9876
```
