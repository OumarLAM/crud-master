#!/bin/bash
set -e

echo "Setting up API Gateway VM..."

# Update package lists and install dependencies
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg2 git

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Load NVM into the current session (this avoids "nvm command not found" errors)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the latest Node.js version using NVM
nvm install node
nvm use node

# Ensure npm is updated to the latest version
npm install -g npm

# Install PM2 globally
npm install -g pm2 && pm2 update

# Create .env file in the API Gateway directory
mkdir -p /vagrant/srcs/api-gateway
cat > /vagrant/srcs/api-gateway/.env << EOL
API_GATEWAY_PORT=${API_GATEWAY_PORT}
API_GATEWAY_HOST=${API_GATEWAY_HOST}
INVENTORY_API_URL=http://192.168.56.11:${INVENTORY_API_PORT}
RABBITMQ_HOST=192.168.56.12
RABBITMQ_PORT=${RABBITMQ_PORT}
RABBITMQ_USER=${RABBITMQ_USER}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
RABBITMQ_BILLING_QUEUE=${RABBITMQ_BILLING_QUEUE}
EOL

echo "API Gateway VM setup completed!"
