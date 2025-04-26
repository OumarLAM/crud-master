#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
apt-get update

# Install Go 1.21
wget -q https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
source /etc/profile

go version
which go

echo "✅ Successfully installed Go"

# Download Node.js binary
wget -q https://nodejs.org/dist/latest-v22.x/node-v22.15.0-linux-x64.tar.gz -O /tmp/node-v22.15.0-linux-x64.tar.gz

# Extract it to /opt
tar -xzf /tmp/node-v22.15.0-linux-x64.tar.gz -C /opt

# Set up the PATH environment variable
echo 'export PATH=/opt/node-v22.15.0-linux-x64/bin:$PATH' >> /etc/profile
source /etc/profile

# Verify installation
node -v
echo "✅ Node and NPM installed successfully"

npm install -g npm@11.3.0
echo "✅ NPM updated successfully"
npm -v

npm install -g pm2

# Build Go API Gateway
cp -r /vagrant/srcs/api-gateway/ /home/vagrant/

# Ensure the vagrant user owns the files
chown -R vagrant:vagrant /home/vagrant/api-gateway

# Start API Gateway with PM2
su - vagrant <<EOF
cd /home/vagrant/api-gateway
sudo pm2 start 'go run ./cmd' --name 'api-gateway'
EOF