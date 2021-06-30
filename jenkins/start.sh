#!/bin/bash

systemctl start jenkins
systemctl stop jenkins
systemctl restart jenkins
systemctl enable jenkins
systemctl disable jenkins


卸载Jenkins
rpm -e jenkins

删除遗留文件:
find / -iname jenkins | xargs -n 1000 rm -rf