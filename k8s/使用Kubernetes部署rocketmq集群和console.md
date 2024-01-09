部署 RocketMQ 集群和 RocketMQ Console 在 Kubernetes 上需要以下步骤。这里假设你已经有一个运行的 Kubernetes 集群。

创建命名空间
-
```shell
kubectl create namespace rocketmq
kubectl config set-context --current --namespace=rocketmq
```

部署 RocketMQ 集群
-
参照前面提到的 [RocketMQ 集群部署方式](./使用Kubernetes部署rocketmq集群.md)，
在 Kubernetes 上配置 StatefulSets 和 Services。
具体文件可以参考之前的 YAML 配置，不过需要注意的是在配置 spec.template.spec.containers 中的 command 时，可能需要考虑在容器启动前等待 NameServer 启动完成。
```shell
kubectl apply -f rocketmq-namesrv-statefulset.yaml
kubectl apply -f rocketmq-broker-statefulset.yaml
```

部署 RocketMQ Console
-
在 Kubernetes 中，我们可以使用 RocketMQ Console 来监控和管理 RocketMQ 集群。以下是一个简单的配置。
- rocketmq-console.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rocketmq-console
spec:
    replicas: 1
    selector:
        matchLabels:
          app: rocketmq-console
    template:
      metadata:
        labels:
          app: rocketmq-console
      spec:
        containers:
        - name: rocketmq-console
          image: styletang/rocketmq-console-ng:2.0.0
          env:
            - name: ROCKETMQ_CONSOLE_PORT
              value: "8080"
            - name: ROCKETMQ_CONSOLE_MQ_ADDR
              value: "rocketmq-namesrv:9876"
          ports:
            - containerPort: 8080
```

```shell
kubectl apply -f rocketmq-console.yaml
```

这里使用了 RocketMQ Console NG 镜像，你可以根据需要选择其他版本。

配置 Ingress
-
如果需要从外部访问 RocketMQ Console，可以配置 Ingress。以下是一个简单的配置例子：
- rocketmq-console-ingress.yaml

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rocketmq-console-ingress
spec:
    rules:
    - host: rocketmq-console.example.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: rocketmq-console
              port:
                number: 8080
```

```shell
kubectl apply -f rocketmq-console-ingress.yaml
```

> 请将 rocketmq-console.example.com 替换为你的域名。

验证
-
等待所有的 Pods 启动完成，然后验证 RocketMQ 集群状态和 RocketMQ Console 是否可以正常访问。
- 获取 NameServer 的 Pod 名称
```shell
namesrv_pod=$(kubectl get pods -l app=rocketmq-namesrv -o jsonpath='{.items[0].metadata.name}')
```

- 查看 NameServer 集群状态
```shell
kubectl exec -it $namesrv_pod -- bin/mqadmin clusterList -n localhost:9876
```

访问 RocketMQ Console，你应该能够通过 Ingress 暴露的地址访问，例如：http://rocketmq-console.example.com。
请注意，以上示例提供了一个基本的配置，实际情况可能需要根据你的需求和环境进行调整。确保你的网络配置正确，服务可以正常访问。同时，考虑安全性，确保只有受信任的网络可以访问 RocketMQ Console。