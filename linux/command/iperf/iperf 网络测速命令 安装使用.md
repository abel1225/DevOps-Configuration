安装：
   因为软件需要使用公网下载服务器连通外网后 wget https://iperf.fr/download/fedora/iperf3-3.1.3-1.fc24.x86_64.rpm 使用yum -y install 安装RPM包

[这里安装的命令是iperf3，使用命令的时候将iperf改为iperf3即可]

参数说明：
-s 以server模式启动。#iperf -s
-c host以client模式启动。host是server端地址。#iperf -c serverip
通用参数：
-f [kmKM] 分别表示以Kbits, Mbits, KBytes, MBytes显示报告，默认以Mbits为单位,#iperf -c 192.168.100.6 -f K
-i sec 以秒为单位显示报告间隔，#iperf -c 192.168.100.6 -i 2
-l 缓冲区大小，默认是8KB,#iperf -c 192.168.100.6 -l 64
-m 显示tcp最大mtu值
-o 将报告和错误信息输出到文件#iperf -c 192.168.100.6 -o ciperflog.txt
-p 指定服务器端使用的端口或客户端所连接的端口#iperf -s -p 5001;iperf -c 192.168.100.55 -p 5001
-u 使用udp协议
-w 指定TCP窗口大小，默认是8KB
-B 绑定一个主机地址或接口（当主机有多个地址或接口时使用该参数）
-C 兼容旧版本（当server端和client端版本不一样时使用）
-M 设定TCP数据包的最大mtu值
-N 设定TCP不延时
-V 传输ipv6数据包

server专用参数：
-D 以服务方式运行。#iperf -s -D
-R 停止iperf服务。针对-D，#iperf -s -R
client端专用参数：
-d 同时进行双向传输测试
-n 指定传输的字节数，#iperf -c 192.168.100.6 -n 1024000
-r 单独进行双向传输测试
-t 测试时间，默认20秒,#iperf -c 192.168.100.6 -t 5
-F 指定需要传输的文件
-T 指定ttl值

测量服务器带宽
使用iperf工具测试服务器带宽，它分为服务端与客户端，两边都要安装iperf工具。在Linux通过yum或者apt-get即可直接安装。

服务端（假设IP为192.168.1.1）运行iperf服务
#iperf -s
客户端
测试上行和下行带宽
#iperf -c 192.168.1.1 -t 60 -d
具体参数可以自行添加
