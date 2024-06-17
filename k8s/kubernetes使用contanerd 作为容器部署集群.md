Kubernetes 是一个开源的容器编排和管理平台，而 containerd 则是一个轻量级的容器运行时，由 Docker 提供，也被 Kubernetes 作为容器运行时的一种选择。以下是在 Kubernetes 中使用 containerd 部署容器集群的一般步骤

步骤概览：
=
1.准备环境：
-
- 安装并配置 Docker（containerd 通常与 Docker 一起安装）。
- 在所有节点上安装 containerd。
- 确保网络设置正确，各节点能够相互通信。

2.安装 Kubernetes 工具：
-
- 安装 kubelet、kubeadm 和 kubectl 工具。这些工具是用于在 Kubernetes 集群上进行操作和管理的核心组件。

3.初始化主节点：
-
- 在主节点上运行 kubeadm init 命令，它将初始化 Kubernetes 控制平面。
- 遵循输出的指示，设置 kubeconfig 等配置文件。

4.部署网络插件：
- 
- 选择一个网络插件（如 Calico、Flannel 等）并按照其文档进行安装。网络插件负责容器之间的通信和集群内部的网络。

5.加入工作节点：
-
- 在每个工作节点上运行 kubeadm join 命令，将其加入到 Kubernetes 集群中。

6.验证集群
-
- 使用 kubectl 命令验证集群的状态，确保所有节点都已成功加入集群。
- 运行一些简单的应用程序来确保容器能够正确运行。

具体操作步骤：
=
步骤 1: 准备环境
-
确保在所有节点上都安装了 containerd。具体安装步骤可以参考 [containerd 官方文档](https://containerd.io)。
安装containerd
- 以下步骤所有节点都执行。

- 安装
```shell
wget https://github.com/containerd/containerd/releases/download/v1.7.2/containerd-1.7.2-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.2-linux-amd64.tar.gz
```
- 修改配置
```shell
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
vim /etc/containerd/config.toml
#SystemdCgroup的值改为true
SystemdCgroup = true
#由于国内下载不到registry.k8s.io的镜像，修改sandbox_image的值为：
sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
```
- 启动服务
```shell
mkdir -p /usr/local/lib/systemd/system
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /usr/local/lib/systemd/system
systemctl daemon-reload
systemctl enable --now containerd
```
- 验证安装
```shell
[root@centos01 opt]# ctr version
Client:
Version:  v1.7.2
Revision: 0cae528dd6cb557f7201036e9f43420650207b58
Go version: go1.20.4

Server:
Version:  v1.7.2
Revision: 0cae528dd6cb557f7201036e9f43420650207b58
UUID: 747cbf1b-17d4-4124-987a-203d8c72de7c
```

步骤 2: 安装 Kubernetes 工具
-
在所有节点上安装 kubelet、kubeadm 和 kubectl。你可以使用以下命令安装：
```shell
sudo apt-get update &amp;&amp; sudo apt-get install -y kubelet kubeadm kubectl
```

步骤 3: 初始化主节点
- 在 Kubelet 启动参数中添加以下内容
```shell
KUBELET_EXTRA_ARGS="--container-runtime=remote \
--container-runtime-endpoint=unix:///var/run/cri-containerd.sock \
--image-service-endpoint=unix:///var/run/cri-containerd.sock"
```
- 在主节点上运行 kubeadm init 命令：
```shell
sudo kubeadm init --pod-network-cidr=CIDR_RANGE
```

其中 CIDR_RANGE 是你选择的网络插件所需的 IP 地址范围。

步骤 4: 部署网络插件
-
选择一个网络插件并按照其文档进行安装。例如，使用 Calico：
```shell
kubectl apply -f https://docs.projectcalico.org/v3.16/manifests/calico.yaml
```

步骤 5: 加入工作节点
-
在每个工作节点上运行 kubeadm join 命令，将其加入到集群中。你需要将命令从主节点的 kubeadm init 输出中复制。

步骤 6: 验证集群
-
等待一段时间，让节点加入集群。然后使用以下命令验证集群状态：

```shell
kubectl get nodes
kubectl get pods --all-namespaces
```

确保所有节点都处于 Ready 状态，且核心组件的所有 Pod 都在运行。
现在，你的 Kubernetes 集群应该已经在 containerd 上成功部署并运行。这只是一个基本的部署流程，具体细节可能会根据你的环境和需求有所不同。