#!/usr/bin/env bash

# 声明: 该脚本适用于升级Centos7的默认openssh到openssh-9.0p1版本

# 定义源码包版本号
OPENSSH_VERSION=openssh-9.0p1
OPENSSL_VERSION=openssl-1.1.1n
ZILB_VERSION=zlib-1.2.11

#日期和升级过程log
log="/usr/local/src/opensshUpgrade/sshupdate_log"

# ifCMD函数,判断上一条命令(不等于0)没执行成就停止,成功就继续运行
function ifCMD() {
    if [ $? -ne 0 ]; then
        exit
    fi
}

# 安装编译环境
yum -y install wget tar gcc make gcc-c++ kernel-devel openssl-devel pam-devel

# 创建/usr/local/src/opensshUpgrade目录
mkdir -p /usr/local/src/opensshUpgrade

# 如果进入目录失败就停止脚本运行
cd /usr/local/src/opensshUpgrade || exit

# 下载源码包
# 下载openssh源码包
wget -c https://ftp.riken.jp/pub/OpenBSD/OpenSSH/portable/$OPENSSH_VERSION.tar.gz --no-check-certificate

ifCMD

# 下载openssl源码包
wget -c https://www.openssl.org/source/$OPENSSL_VERSION.tar.gz --no-check-certificate

ifCMD

# 下载zlib源码包
wget -c https://nchc.dl.sourceforge.net/project/libpng/zlib/1.2.11/$ZILB_VERSION.tar.gz --no-check-certificate

ifCMD

# 解压安装包，我习惯将安装包解压到/usr/local/src,如果解压失败就推出
tar xf $OPENSSH_VERSION.tar.gz -C /usr/local/src/
tar xf $OPENSSL_VERSION.tar.gz -C /usr/local/src/
tar xf $ZILB_VERSION.tar.gz -C /usr/local/src/

# 安装zlib-1.2.11
cd /usr/local/src/$ZILB_VERSION/ || exit
./configure --prefix=/usr/local/zlib && make -j && make install
ifCMD

# 备份旧版的openssl和动态库
mv /usr/bin/openssl{,.bak} &>/dev/null
mv /usr/include/openssl{,.bak} &>/dev/null
ifCMD

# 安装 openssl
cd /usr/local/src/$OPENSSL_VERSION/ || exit
./config --prefix=/usr/local/openssl -d shared
make -j && make install
ifCMD

# 创建软连接到/usr/bin/openssl
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ifCMD

#检查函数库
ldd /usr/local/openssl/bin/openssl

#添加所缺函数库
echo '/usr/local/openssl/lib' >>/etc/ld.so.conf

# 更新函数
ldconfig -v

# 备份 /etc/ssh 原有配置文件，并将新的配置复制到指定目录
mv /etc/ssh{,.bak} &>/dev/null

# 备份原ssh
mv /usr/bin/ssh{,.bak} &>/dev/null

# 备份原sshd
mv /usr/sbin/sshd{,.bak} &>/dev/null

# 备份原ssh-kegen
mv /usr/sbin/sshd-keygen{,.bak} &>/dev/null
mv /usr/bin/ssh-keygen{,.bak} &>/dev/null


# 将sftp-server移动到openssh指定的位置
mv /usr/libexec/openssh/sftp-server /usr/libexec/sftp-server

# 备份环境变量文件
mv /etc/sysconfig/sshd{,.bak} &>/dev/null

# 备份完成后卸载原openssh
# yum autoremove openssh -y
yum erase openssh -y

ifCMD

# 确保openssl升级完,编译安装openssh
cd /usr/local/src/$OPENSSH_VERSION/ || exit
./configure --prefix=/usr/local/openssh \
    --sysconfdir=/etc/ssh \
    --mandir=/usr/share/man \
    --with-ssl-dir=/usr/local/openssl \
    --with-zlib=/usr/local/zlib

make -j && make install

ifCMD

# 配置私钥的权限
chown root:ssh_keys /etc/ssh/*_key

# sshd禁用scp协议,创建这个文件即可
touch /etc/ssh/disable_scp

# 将对应文件复制到指定路径
cp -rf /usr/local/openssh/sbin/sshd /usr/sbin/sshd
cp -rf /usr/local/openssh/bin/ssh /usr/bin/ssh
cp -rf /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
chmod 755 /usr/sbin/sshd
chmod 755 /usr/bin/ssh
chmod 755 /usr/bin/ssh-keygen

# 恢复sshd-keygen
cp /usr/sbin/sshd-keygen.bak /usr/sbin/sshd-keygen &>/dev/null


# 恢复sshd的变量文件
cp /etc/sysconfig/sshd.bak /etc/sysconfig/sshd

# 复制启动脚本文件到 /etc/init.d/sshd系统文件夹
# cd /usr/local/src/openssh-9.0p1/contrib/redhat || exit
# cp sshd.init /etc/init.d/sshd

# 恢复原来的sshd_config配置
# cp /etc/ssh.bak/sshd_config /etc/ssh/sshd_config
# grep -Ev "^$|#" cp /etc/ssh.bak/sshd_config >/etc/ssh/sshd_config

# 将ssh9的sshd_config文件复制到/etc/ssh/sshd_config
cp /usr/local/src/openssh-9.0p1/sshd_config /etc/ssh/sshd_config

# 注释下面三个配置
## openssh9 提示sshd_config提示不支持的参数

#  GSSAPIAuthentication yes
# sed -i 's/^GSSAPIAuthentication /# GSSAPIAuthentication yes/' /etc/ssh/sshd_config
# GSSAPICleanupCredentials no
# sed -i 's/^GSSAPICleanupCredentials /# GSSAPICleanupCredentials no/' /etc/ssh/sshd_config
# UsePAM yes
# sed -i 's/^UsePAM /# UsePAM yes/' /etc/ssh/sshd_config


# sshd_config文件修改
# cp /usr/local/openssh/etc/sshd_config /etc/ssh/sshd_config
# 开启x11转发
# echo "X11Forwarding yes" >> /etc/ssh/sshd_config
# X11配置
# echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
# X11认证配置
# echo "XAuthLocation /usr/bin/xauth" >> /etc/ssh/sshd_config
# 禁用DNS反查,加快ssh登录速度
# echo "UseDNS no" >>/etc/ssh/sshd_config
# # 允许root登录
echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
# # 允许密钥登录
# echo 'PubkeyAuthentication yes' >>/etc/ssh/sshd_config
# # 允许密码登录
# echo 'PasswordAuthentication yes' >>/etc/ssh/sshd_config

# 获取旧版sshd进程的pid
pgrep sshd

# 停止旧版 sshd 服务
systemctl stop sshd.service

# 删除旧版的sshd服务启动文件
sshd_service_FILE=/lib/systemd/system/sshd.service
if [ -f "$sshd_service_FILE" ]; then
    rm -rf /usr/lib/systemd/system/sshd.service
    echo "/usr/lib/systemd/system/sshd.service  已清除" >>${log}
fi

# 判断/etc/systemd/system/multi-user.target.wants/sshd.service文件是否存在
if [ -f /etc/systemd/system/multi-user.target.wants/sshd.service ]; then
    rm -rf /etc/systemd/system/multi-user.target.wants/sshd.service
    echo "/etc/systemd/system/multi-user.target.wants/sshd.service  已清除" >>${log}
else
    echo "/etc/systemd/system/multi-user.target.wants/sshd.service  文件不存在" >>${log}
fi

# 写入sshd-keygen.service文件
echo "
[Unit]
Description=OpenSSH Server Key Generation
Conditionsshd_service_FILENotEmpty=|!/etc/ssh/ssh_host_rsa_key
Conditionsshd_service_FILENotEmpty=|!/etc/ssh/ssh_host_ecdsa_key
Conditionsshd_service_FILENotEmpty=|!/etc/ssh/ssh_host_ed25519_key
PartOf=sshd.service sshd.socket

[Service]
ExecStart=/usr/sbin/sshd-keygen
Type=oneshot
RemainAfterExit=yes
" >/usr/lib/systemd/system/sshd-keygen.service

# 写入sshd.socket
echo "
[Unit]
Description=OpenSSH Server Socket
Documentation=man:sshd(8) man:sshd_config(5)
Conflicts=sshd.service

[Socket]
ListenStream=22
Accept=yes

[Install]
WantedBy=sockets.target
" >/usr/lib/systemd/system/sshd.socket

# 写入sshd.service文件
echo "
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service
Wants=sshd-keygen.service

[Service]
# 这里的type只能是simple,notify会获取不到satus
Type=simple
Environmentsshd_service_FILE=/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D \$OPTIONS
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
" >/usr/lib/systemd/system/sshd.service

# 修改了服务文件,需要重新载入systemd
systemctl daemon-reload

# 设置开机自启动
systemctl enable --now sshd

# 重新启动sshd
systemctl Restart sshd

ifCMD

# 查看sshd服务是否启动
systemctl status sshd | grep "Active: active (running)"

# 查看openssh版本和openssl版本
sshd -V
ssh -v
openssl version

# 打印是否升级成功
if [ $? -eq 0 ]; then
    echo -e "\033[32m[INFO] OpenSSH upgraded to $OPENSSH_VERSION  successfully！\033[0m"
else
    echo -e "\033[31m[ERROR] OpenSSH upgraded to $OPENSSH_VERSION faild！\033[0m"
fi

