# 异常信息：error: unable to recognize "calico.yaml": no matches for kind "PodDisruptionBudget" in version "policy/v1"
原因：calico版本 与 k8s版本不匹配
查看k8s对应的calico的版本 https://projectcalico.docs.tigera.io/archive/v3.20/getting-started/kubernetes/requirements

# Unable to register node "izbp17s66p5uyhqc42e3acz" with API server:
## 查看apiserver的service文件存储路径
systemctl status kube-apiserver | grep load
## 查找apiserver的启动参数，查看ca证书的存储路径
cat /usr/lib/systemd/system/kube-apiserver.service
## 查看EnviromentFile，或者直接可以看到启动参数，以实际的为准
grep 'ca.pem' /opt/k8s/etc/kubernetes/apiserver
## 使用openssl命令查看证书过期时间
openssl x509 -noout -text -in /opt/k8s/etc/kubernetes/ssl/ca.pem | grep Not
