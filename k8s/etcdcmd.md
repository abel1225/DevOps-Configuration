## etcdctl 常用操作
etcdctl cluster-health #检查网络集群健康状态
etcdctl --endpoints=https://192.168.71.221:2379 cluster-health #带有安全认证检查网络集群健康状态
etcdctl member list
etcdctl set /k8s/network/config ‘{ “Network”: “10.1.0.0/16” }’
etcdctl get /k8s/network/config