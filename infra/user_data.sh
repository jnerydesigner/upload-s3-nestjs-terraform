#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -xe

yum update -y
yum install -y docker awscli

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

mkdir -p /home/ec2-user/certs

# Recupera certificados SSL
aws ssm get-parameter --name "/seligadev/SSL_KEY" --with-decryption --query "Parameter.Value" --output text > /home/ec2-user/certs/key.pem
aws ssm get-parameter --name "/seligadev/SSL_CERT" --with-decryption --query "Parameter.Value" --output text > /home/ec2-user/certs/cert.pem
chown ec2-user:ec2-user /home/ec2-user/certs/*

# Cria arquivo .env com variáveis de ambiente
cat <<EOF > /home/ec2-user/app.env
AWS_ACCESS_KEY_ID=$(aws ssm get-parameter --name "/seligadev/AWS_ACCESS_KEY_ID" --with-decryption --query "Parameter.Value" --output text | tr -d '\r\n')
AWS_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name "/seligadev/AWS_SECRET_ACCESS_KEY" --with-decryption --query "Parameter.Value" --output text | tr -d '\r\n')
AWS_BUCKET_NAME=s3-nest-upload
AWS_REGION=us-east-1
APP_NAME=seligadev
SSL_KEY=$(cat /home/ec2-user/certs/key.pem)
SSL_CERT=$(cat /home/ec2-user/certs/cert.pem)
SERVER_PORT=3388
EOF

chown ec2-user:ec2-user /home/ec2-user/app.env


# Inicia o container com o arquivo de ambiente
docker run -d --restart unless-stopped -p 3388:3388 \
  -v /home/ec2-user/certs:/app/certs \
  --env-file /home/ec2-user/app.env \
  jandernery/upload-s3-nodejs:latest
