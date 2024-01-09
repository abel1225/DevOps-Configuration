在 Kubernetes Ingress 中，secret 配置用于定义与 TLS 相关的密钥和证书信息，以启用 HTTPS 支持。以下是有关 Ingress 中 secret 配置的详细说明：

创建 TLS Secret
-
- 首先，你需要创建一个 Kubernetes 的 Secret 对象，用于存储 TLS 证书和密钥。这个 Secret 对象将在 Ingress 中引用。
```yaml
   apiVersion: v1
   kind: Secret
   metadata:
    name: my-tls-secret
   type: kubernetes.io/tls
   data:
    tls.crt: <base64-encoded-certificate>
    tls.key: <base64-encoded-private-key>
```


- my-tls-secret: 这是 Secret 对象的名称，你可以根据需要进行命名。
- type: kubernetes.io/tls: 这表示这是一个 TLS 类型的 Secret。
- data: 在这里，你需要提供经过 Base64 编码的证书 (tls.crt) 和私钥 (tls.key)。你可以使用 echo -n '&lt;certificate-content&gt;' | base64 来对证书和私钥进行编码，
- 注：data这里不能直接使用secret的路径来写入。

在 Ingress 中引用 Secret
-
- 一旦你创建了 TLS Secret，接下来在 Ingress 中引用它，以启用 HTTPS 支持。
```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
    name: my-ingress
   spec:
    rules:
    - host: example.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: my-service
              port:
                number: 80
    tls:
    - hosts:
      - example.com
      secretName: my-tls-secret
```


- tls
> 在 Ingress 规则中，你可以通过 tls 字段指定启用 TLS 的主机和相应的 TLS Secret。
- hosts
> 定义哪些主机名应该启用 TLS。在上面的例子中，只有 example.com 启用了 TLS。

注意事项：
-
- 证书和私钥的更新
> 如果需要更新证书或私钥，你可以创建一个新的 Secret，然后在 Ingress 中更新 secretName 字段，Kubernetes 将自动更新 Ingress。
- 证书管理工具
> 对于大规模的证书管理，你可能会考虑使用证书管理工具，如 Cert-Manager，它可以自动化证书的颁发和更新。
- 自签名证书
> 除了从证书颁发机构获取的证书外，你也可以使用自签名证书。在这种情况下，只需将自签名证书和私钥存储在 TLS Secret 中即可。

通过配置 secret，你可以在 Kubernetes Ingress 中启用 TLS，确保传输过程中的安全性。请注意，证书的安全性和合法性直接影响到你的应用程序的安全性，因此应小心管理证书。