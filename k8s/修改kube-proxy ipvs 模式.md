## kubernetes 默认的kube-proxy模式位iptables，但是iptables clusterip不能互相ping通，所以需要把iptables切换为ipvs
1. 查看kube-proxy
```shell
kubectl get pods -n kube-system -o wide | grep proxy
```

2. 查看pod的proxy模式
```shell
kubectl logs kube-proxy-xxx -n kube-system
```

3. 启动ipvs模块
```shell
kubectl edit configmap kube-proxy -n kube-system
```
```yaml
iptables:
     masqueradeAll: false
     masqueradeBit: 14
     minSyncPeriod: 0s
     syncPeriod: 30s
ipvs:
     excludeCIDRs: null
     minSyncPeriod: 0s
     scheduler: ""      # 可以在这里修改ipvs的算法,默认为rr轮循算法,一般有rr, wrr, lr, wlr算法
     strictARP: false
     syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: "ipvs"      # 默认""号里为空,加上ipvs
```
或者
```shell
cat <<EOF >/etc/sysconfig/modules/ipvs.modules
#!/bin/bash
ipvs_modules_dir="/usr/lib/modules/`uname -r`/kernel/net/netfilter/ipvs"
for i in \`ls \$ipvs_modules_dir | sed -r 's#(.*).ko.xz#\1#'\`; do
      /sbin/modinfo -F filename \$i &> /dev/null
      if [ \$? -eq 0 ]; then
          /sbin/modprobe \$i
       fi
done
EOF

chmod +x /etc/sysconfig/modules/ipvs.modules ; bash /etc/sysconfig/modules/ipvs.modules
```

4. 确保所有节点的ipvs模块都已经运行
```shell
lsmod | grep ip_vs
```