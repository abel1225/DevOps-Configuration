## --- 安装依赖
#1.安装calico-etcd based
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico-etcd.yaml -o calico.yaml
kubectl apply -f calico.yaml

## --- 安装kubesphere
### 1.核心文件下载和配置更新
yum install -y  wget

wget https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/kubesphere-installer.yaml
wget https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/cluster-configuration.yaml

yum install -y vim

vim cluster-configuration.yaml
 #修改spec.etcd.monitoring的值为true
 #修改spec.etcd.endpointIps的值为master节点的内网ip
 #修改spec.common.redis.enabled的值为true
 #修改spec.common.openldap的值为true,开启轻量级目录协议
 #修改spec.alerting.enabled的值为true
 #修改spec.auditing.enabled的值为true
 #修改spec.devops.enabled的值为true
 #修改spec.events.enabled的值为true
 #修改spec.logging.enabled的值为true
 #修改spec.network.networkpolicy.enabled的值为true
 #修改spec.network.ippool.type的值为calico
 #修改spec.openpitrix.store.enabled的值为true，开启应用商店
 #修改spec.servicemesh.enabled的值为true,开启微服务治理功能
 #修改spec.kubeedge.enabled的值为true,开启边缘服务，可以不打开，体验不到

### 2.执行安装命令
kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml
验证：执行kubectl get pod -A,查看ks-installer是否Runnig，大概3分钟左右会Running。
### 3.查看安装进度
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
在master节点执行kubectl get pod -A,等所有的pod都是正常运行之后再访问。
### 4.查看pod启动异常原因
kubectl describe pod -n kubesphere-monitoring-system(名称空间) alertmanager-main-1（pod名字）
### 5.解决etcd监控证书找不到的问题
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  --from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  --from-file=etcd-client.crt=/etc/kubernetes/pki/apiserver-etcd-client.crt  --from-file=etcd-client.key=/etc/kubernetes/pki/apiserver-etcd-client.key

### 6.访问任意机器的 30880端口，注意要在每一台机器的安全组里放行30880端口


