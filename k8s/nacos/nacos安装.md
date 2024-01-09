# 部署PV
kubectl  apply -f  nacos-pv.yaml
# 部署PVC
kubectl  apply -f  nacos-pvc.yaml 
# 部署 configmap
kubectl create configmap nacos-custom.properties --from-file=./custom.properties -n devops
## 查看 configmap
kubectl  get cm -n devops
# 部署nacos-deployment
kubectl apply -f  nacos-deployment.yaml 

# 部署Nacos-svc
kubectl apply -f nacos-svc.yaml 

# 部署nacos-ingress
kubectl apply -f nacos-ingress.yaml 
