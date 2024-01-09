# pods 状态持续Pending 问题排查
1. kubectl get pods [-n devops] 获取pods
2. kubectl get pod <pod-name> -o yaml 查看 Pod 的配置是否正确
3. kubectl describe pod <pod-name> 查看 Pod 的事件
4. kubectl logs <pod-name> [-c <container-name>] 查看容器日志
5. kubectl get events [-n devops] 查看事件
# kubectl get pv,pvc 命令返回 No resources found
创建pv和pvc