#!/bin/bash
set -e

echo "Setting up API Gateway VM..."

# Update package lists and install dependencies
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg2 git wget
echo "✅ Successfully installed dependencies"

# Install Go
GO_VERSION="1.24.1"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Add Go to PATH permanently
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

# Verify Go installation
go version

# Create .env file in the API Gateway directory
mkdir -p /vagrant/srcs/api-gateway
cat > /vagrant/srcs/api-gateway/.env << EOL
API_GATEWAY_PORT=${API_GATEWAY_PORT}
API_GATEWAY_HOST=${API_GATEWAY_HOST}
INVENTORY_API_URL=http://${INVENTORY_API_HOST}:${INVENTORY_API_PORT}
RABBITMQ_URL=${RABBITMQ_URL}
RABBITMQ_HOST=${RABBITMQ_HOST}
RABBITMQ_PORT=${RABBITMQ_PORT}
RABBITMQ_USER=${RABBITMQ_USER}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
RABBITMQ_QUEUE=${RABBITMQ_QUEUE}
EOL

cd /vagrant/srcs/api-gateway

# Build the API Gateway
if [ ! -f go.mod ]; then
  go mod init api-gateway
  go mod tidy
fi

# Check if main.go exists in the cmd directory
if [ ! -f cmd/main.go ]; then
  echo "Error: No main.go file found in $(pwd)/cmd. Cannot build API Gateway."
  exit 1
fi

go build -o api-gateway ./cmd

# Start the API Gateway
nohup ./api-gateway &

echo "API Gateway VM setup completed!"