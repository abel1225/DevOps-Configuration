# 安装所需资源包
sudo yum install -y yum-utils
# 设置docker下载地址
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
# 安装docker
sudo yum install docker-ce docker-ce-cli containerd.io

# 启动
sudo systemctl start docker

# 开机自启动
systemctl enable docker

# 后台运行
sudo systemctl daemon-reload

# 配置镜像加速
1、去到阿里云官方网址，找到容器镜像服务：
https://www.aliyun.com/product/acr?spm=5176.19720258.J_3207526240.30.3cb876f4HGkuU9
2、进入管理控制台（这里没有开通服务的需要开通一下容器服务）

3、点击镜像加速器，选择CentOS
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://9h8l8wkd.mirror.aliyuncs.com"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker


