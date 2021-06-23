#!/bin/bash

systemctl start jenkins
systemctl stop jenkins
systemctl restart jenkins
systemctl enable jenkins
systemctl disable jenkins
