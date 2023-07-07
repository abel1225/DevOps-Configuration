## 为 Docker daemon 配置 Docker Hub 的中国官方镜像加速 https://registry.docker-cn.com

## 下载并启动启动docker Desktop里的k8s
git clone https://github.com/loverto/k8s-for-docker-desktop

git branch -a

git checkout -b 18.09.1 origin/18.09.1

cd k8s-for-docker-desktop

./load_images.sh

## 几分钟后，运行命令检验

kubectl get pods --all-namespaces

## 说明
如果k8s一直处于starting状态，说明kube配置异常
删除用户目录下的.kube目录后重启docker即可
rm -rf ～/.kube


## 注意事项
  docker中的k8s版本和k8s-for-docker-desktop中k8s版本可能不一致，k8s-for-docker-desktop这里有好几个分支，
  根据需要选择跟自己docker Desktop里k8s一致的分支。
