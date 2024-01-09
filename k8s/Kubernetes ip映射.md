在 Kubernetes 中，IP 映射（IP Mapping）通常是通过 Service 资源来实现的。Service 充当了一个抽象层，将后端 Pod 的 IP 地址映射到一个虚拟的 Cluster IP 或外部 IP。这样，其他服务或外部用户可以通过这个虚拟 IP 来访问服务，而不需要关心后端 Pod 的具体 IP 地址。以下是几种 Kubernetes 中实现 IP 映射的方式：

Cluster IP
-
- 默认情况下，Kubernetes Service 会创建一个 Cluster IP，这是一个虚拟 IP，用于将请求负载均衡到 Service 的后端 Pod。
- 这是默认的 Service 类型，不需要额外的配置。可以通过 kubectl expose 或 YAML 文件中指定 type: ClusterIP 来创建 Cluster IP。
```yaml

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

NodePort
-
- NodePort Service 类型在 Cluster IP 的基础上提供了在每个节点上暴露相同端口的功能。这样，可以通过节点的 IP 和指定的 NodePort 来访问服务。
- 在 Service 的配置中指定 type: NodePort，Kubernetes 将选择一个随机的端口，也可以通过 nodePort 字段指定端口。
```yaml

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  type: NodePort
```

LoadBalancer
-
- LoadBalancer Service 类型通过云服务提供商（如 AWS、GCP、Azure）提供的负载均衡器来公开服务。负载均衡器将外部流量分发到集群中的节点上。
- 在 Service 的配置中指定 type: LoadBalancer，Kubernetes 将与云提供商集成，自动创建并配置负载均衡器。
```yaml

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  type: LoadBalancer
```

ExternalName
-
- ExternalName Service 类型将服务映射到集群外部的 DNS 名称。它不会创建 Cluster IP 或引入任何负载均衡。
- 在 Service 的配置中指定 type: ExternalName，并使用 externalName 字段指定目标服务的 DNS 名称。
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ExternalName
  externalName: my-service.my-external-domain.com
```

这些是 Kubernetes 中几种常见的 IP 映射配置方式。选择合适的方式取决于你的应用需求和环境。