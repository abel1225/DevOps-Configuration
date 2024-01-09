# 基础环境准备

### 各个机器设置自己的域名
hostnamectl set-hostname xxxx


### 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

### 关闭swap
swapoff -a  
sed -ri 's/.*swap.*/#&/' /etc/fstab

### 允许 iptables 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# 安装kubelet、kubeadm、kubectl
### 镜像设置
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

### 执行安装(注意版本号保持一致)
sudo yum install -y kubelet-1.20.9 kubeadm-1.20.9 kubectl-1.20.9 --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

# 使用kubeadm引导集群
### 安装镜像
sudo tee ./images.sh <<-'EOF'
#!/bin/bash
images=(
kube-apiserver:v1.20.9
kube-proxy:v1.20.9
kube-controller-manager:v1.20.9
kube-scheduler:v1.20.9
coredns:1.7.0
etcd:3.4.13-0
pause:3.2
)
for imageName in ${images[@]} ; do
docker pull registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/$imageName
done
EOF

chmod +x ./images.sh && ./images.sh

### 节点初始化

#所有机器添加master域名映射，以下需要修改为自己的 [172.28.218.139]
#echo "172.28.218.139  cluster-endpoint" >> /etc/hosts
echo "172.28.218.139  master" >> /etc/hosts

#主节点初始化
kubeadm init \
--apiserver-advertise-address=172.28.218.139 \
--control-plane-endpoint=master \
--image-repository registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images \
--kubernetes-version v1.20.9 \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=192.168.0.0/16 \
--ignore-preflight-errors=all

说明：所有网络范围不重叠这里是k8s内部的网段，且不能与服务器设置的专有网络重叠
–service-cidr=10.96.0.0/16
–pod-network-cidr=192.168.0.0/16

#重置kubeadm状态
kubeadm reset

注: 报错 the number of available CPUs 1 is less than the required 2
解决措施有两种方法：
其一： 虚拟机话，可以提升虚拟机的cpu资源
其二：忽视这条告警错误，加上 --ignore-preflight-errors=all 参数即可。

## 生成的信息
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

kubeadm join master:6443 --token uegcvz.1olnaxiuaf7dfrol \
--discovery-token-ca-cert-hash sha256:bf3f796bbb82f0a2806bc99707b21b938467a397e7d378d8a60f45e58762c0bc \
--control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join master:6443 --token uegcvz.1olnaxiuaf7dfrol \
--discovery-token-ca-cert-hash sha256:bf3f796bbb82f0a2806bc99707b21b938467a397e7d378d8a60f45e58762c0bc

## 执行上述信息中的命令

# 安装网络组件
curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml

注：如果这里在之前主节点初始化时修改了
–pod-network-cidr=192.168.0.0/16
那么就需要你重新修改 calico.yaml 中的配置与之保持一致








