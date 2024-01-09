为了在 Kubernetes 上安装 MongoDB 集群、设置认证、将数据写入宿主机目录 /data/mongo 并提供服务给其他应用调用，我们可以分为以下几个步骤：

步骤概览
=
创建命名空间：
-
- 为 MongoDB 集群创建一个专用的 Kubernetes 命名空间：
```shell
kubectl create namespace mongo
```
创建 MongoDB 的 StatefulSet 和服务：
-
- 使用 StatefulSet 配置 MongoDB 集群。创建一个文件（例如 mongo-statefulset-auth.yaml）：
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
  namespace: mongo
spec:
  serviceName: "mongo"
  replicas: 3
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
        - name: mongo
          image: mongo
          command: ["mongod", "--auth", "--replSet", "rs0"]
          ports:
          - containerPort: 27017
            name: mongo
          volumeMounts:
          - name: mongo-persistent-storage
            mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-persistent-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi

---
apiVersion: v1
kind: Service
metadata:
  name: mongo
  namespace: mongo
spec:
  selector:
    app: mongo
  ports:
    - protocol: TCP
      port: 27017
      targetPort: 27017
```


使用以下命令应用配置文件
-

```yaml
kubectl apply -f mongo-statefulset-auth.yaml
```


等待 StatefulSet 就绪：
-
- 使用以下命令检查 StatefulSet 中的 Pod 是否就绪：
```shell
kubectl get pods -n mongo
```

> 等待所有 Pod 的 READY 列都显示 1/1。

配置 Replica Set：
-
- 进入一个 Pod，并连接到 MongoDB 数据库：
```shell
kubectl exec -it mongo-0 -n mongo -- mongo
```

在 mongo shell 中执行以下命令来配置 Replica Set：
-
```javascript
config = {
_id: "rs0",
members: [
{_id: 0, host: "mongo-0.mongo:27017"},
{_id: 1, host: "mongo-1.mongo:27017"},
{_Id: 2, host: "mongo-2.mongo:27017"}
]
}

rs.initiate(config)
```

退出 mongo shell：
-
```javascript
quit()
```

创建管理员用户：
-
- 进入任一 Pod，并连接到 MongoDB 数据库：
```shell
kubectl exec -it mongo-0 -n mongo -- mongo
```
- 在 mongo shell 中执行以下命令
```javascript
use admin
db.createUser(
{
user: "admin",
pwd: "adminpassword",
roles: [ { role: "root", db: "admin" } ]
}
)
```
- 退出 mongo shell：
```javascript
quit()
```

启用认证：
-
- 修改 mongo-statefulset-auth.yaml 文件，在 command 部分添加 --auth：

```yaml
containers:
- name: mongo
  image: mongo
  command: ["mongod", "--auth", "--replSet", "rs0"]
  ports:
- containerPort: 27017
  name: mongo
  volumeMounts:
- name: mongo-persistent-storage
  mountPath: /data/db
```


使用 kubectl apply 应用修改：
-
```shell
kubectl apply -f mongo-statefulset-auth.yaml
```

验证认证设置：
-
- 进入任一 Pod，并连接到 MongoDB 数据库：
```shell
kubectl exec -it mongo-0 -n mongo -- mongo -u admin -p adminpassword --authenticationDatabase admin
```
> 如果成功连接，认证设置正常。

将数据写入宿主机目录：
-
- 在 StatefulSet 的配置文件中，volumeClaimTemplates 部分定义了数据的持久卷。你需要为这个持久卷提供一个主机路径，以便数据写入宿主机。修改 mongo-statefulset-auth.yaml 文件：
```yaml
volumeClaimTemplates:
- metadata:
  name: mongo-persistent-storage
  spec:
  accessModes: [ "ReadWriteOnce" ]
  resources:
  requests:
  storage: 1Gi
  storageClassName: "your-storage-class-name"
```
> 确保替换 your-storage-class-name 为你实际使用的存储类。

- 创建宿主机目录 /data/mongo
```shell
mkdir -p /data/mongo
```
- 然后将宿主机目录挂载到 StatefulSet 中的持久卷上。修改 mongo-statefulset-auth.yaml 文件：
```yaml
volumeMounts:
- name: mongo-persistent-storage
  mountPath: /data/mongo
```

- 使用 kubectl apply 应用修改：
```shell
kubectl apply -f mongo-statefulset-auth.yaml
```

暴露 MongoDB 服务给其他应用
-
- 你可以使用 Kubernetes 的 Service 来将 MongoDB 服务暴露给其他应用。在上述的 StatefulSet 配置文件中，已经创建了一个名为 mongo 的 Service。
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo
  namespace: mongo
spec:
  selector:
    app: mongo
  ports:
    - protocol: TCP
      port: 27017
      targetPort: 27017
```
> 通过这个 Service，其他应用可以通过 mongo:27017 地址访问 MongoDB 服务。

验证服务可用性：
-
- 在其他应用中使用 MongoDB 的连接字符串，指定连接到 mongo:27017。

现在，你已经成功在 Kubernetes 上安装了 MongoDB 集群，启用了认证，并将数据写入宿主机目录 /data/mongo。其他应用可以通过 mongo:27017 地址访问 MongoDB 服务。根据实际需求和安全性考虑，你可能需要进一步调整 MongoDB

添加外网调用
=
> 为了允许外部应用调用你的 MongoDB 服务，你可以通过 Kubernetes 的 Service 配置来将 MongoDB Service 暴露到外部。以下是一种使用 Kubernetes 的 NodePort 方式暴露服务的方法：

创建 NodePort Service
-
- 在 MongoDB 的 Service 配置中，使用 type: NodePort 来创建一个 NodePort Service。修改之前创建的 mongo Service 的配置文件，例如 mongo-service.yaml：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo
  namespace: mongo
spec:
  selector:
    app: mongo
  ports:
  - protocol: TCP
    port: 27017
    targetPort: 27017
  type: NodePort
```

- 使用以下命令应用配置文件：
```shell
kubectl apply -f mongo-service.yaml
```


查找分配的 NodePort 端口：
-
- 使用以下命令查找分配的 NodePort 端口：
```shell
kubectl get svc mongo -n mongo
```
> 这将显示你的 MongoDB Service 的相关信息，包括分配的 NodePort。

访问 MongoDB 服务
-
> 现在，你可以使用任何能够访问你的 Kubernetes 集群的设备，通过 &lt;Node_IP&gt;:&lt;NodePort&gt; 地址来访问 MongoDB 服务。其中，&lt;Node_IP&gt; 是任意 Kubernetes 集群节点的外部 IP 地址，&lt;NodePort&gt; 是你之前查找到的分配的 NodePort。
例如，如果你的节点 IP 地址是 192.168.1.100，NodePort 是 32000，那么 MongoDB 可以通过 192.168.1.100:32000 进行访问。

使用Ingress配置外网调用
=
> 使用 Ingress 来将 MongoDB 服务暴露到外部网络通常涉及以下步骤。在这里，我将使用 Kubernetes Ingress 控制器和 MongoDB 服务的示例进行说明：

安装 Ingress 控制器：
-
- 首先，确保你的 Kubernetes 集群中已经安装了 Ingress 控制器。常见的 Ingress 控制器包括 Nginx Ingress Controller、Traefik、Haproxy Ingress 等。你可以根据你的需求选择其中之一，并按照其文档进行安装。
以下是使用 Nginx Ingress Controller 的示例命令：
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```


为 MongoDB 创建 Ingress 资源：
-
- 创建一个 Ingress 资源，将外部请求路由到 MongoDB Service。以下是一个示例 Ingress 配置文件 mongo-ingress.yaml：
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mongo-ingress
  namespace: mongo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
    rules:
    - host: your-domain.com # 替换为你的域名
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: mongo
              port:
                number: 27017
```
> 请替换 your-domain.com 为你的域名。这个 Ingress 配置将外部流量路由到 MongoDB Service 的端口 27017。

应用 Ingress 资源：
-
- 使用以下命令应用 Ingress 资源：
```shell
kubectl apply -f mongo-ingress.yaml
```

配置 DNS：
-
> 如果你使用的是域名来访问服务，确保你的域名解析指向 Kubernetes 集群的外部 IP。你可以通过云服务提供商的控制台或者本地 DNS 配置来完成这一步。

访问 MongoDB 服务
-
> 现在，你可以通过你的域名（或者集群的外部 IP）来访问 MongoDB 服务了。例如，使用 your-domain.com 或者外部 IP 地址。

> 请注意，Ingress 配置的详细内容可能会因为你选择的 Ingress 控制器和集群的具体环境而有所不同。确保查阅相应控制器的文档以获取更多详细信息。此外，为了安全考虑，你可能需要考虑配置 Ingress 控制器以支持 HTTPS，并使用 TLS 证书来加密通信。