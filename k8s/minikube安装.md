# minikube安装
curl -Lo minikube https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.18.1/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# 启动minikube
minikube start --driver='docker' --image-mirror-country='cn' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers'
