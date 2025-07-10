#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

yum update -y
yum install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user
