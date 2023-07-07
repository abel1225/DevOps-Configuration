## 获取dashboard
curl https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml -0 kubernetes-dashboard-recommended.yaml
提示：获取之前先判断kubernetes的版本是否和dashboard匹配
https://github.com/kubernetes/dashboard/releases
## 安装dashboard服务
kubectl apply -f kubernetes-dashboard-recommended.yaml
## 角色权限绑定
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard
## 获取登陆token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
## 启用dashboard代理
kubectl proxy
kubectl 会使得 Dashboard 可以通过 http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ 访问
## 查看暴露的端口
kubectl get pods,svc -n kube-system

### 提示:
###  dashboard有以下三种访问方式：
kubectl proxy：只能在localhost上访问。访问地址：http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
NodePort：编辑 kubernetes-dashboard.yaml文件中，将 type: ClusterIP 改为 type: NodePort，确认dashboard运行在哪个节点后。访问地址：https://<node-ip>:<nodePort>
apiserver：需要在浏览器中安装用户证书。访问地址： https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
提示：kubectl proxy方式不推荐，建议使用有效证书来建立安全的HTTPS连接。

建议通过后端形式，并且允许所有主机访问的方式：
nohup kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' &