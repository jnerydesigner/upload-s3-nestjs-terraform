#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

yum update -y
yum install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user



docker run -d --restart unless-stopped -p 3388:3388 \
  -v /home/ec2-user/certs:/app/certs \
  -e AWS_BUCKET_NAME=s3-nest-upload \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  jandernery/upload-s3-nodejs:latest
