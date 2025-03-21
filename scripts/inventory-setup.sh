#!/bin/bash
set -e

echo "Setting up Inventory API VM..."

# Update package lists and install dependencies
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg2 git postgresql postgresql-contrib
echo "✅ Successfully installed dependencies"

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Load NVM into the current session (this avoids "nvm command not found" errors)
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Install the latest Node.js version using NVM
nvm install node
nvm use node

# Ensure npm is updated to the latest version
npm install -g npm

# Install PM2 globally
npm install -g pm2 && pm2 update

# Start PostgreSQL and enable it to start at boot
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${POSTGRES_INVENTORY_USER}'" | grep -q 1 ||
sudo -u postgres psql -c "CREATE USER ${POSTGRES_INVENTORY_USER} WITH PASSWORD '${POSTGRES_INVENTORY_PASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_INVENTORY_DB};"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_INVENTORY_DB} TO ${POSTGRES_INVENTORY_USER};"

# Create .env file in the Inventory API directory
mkdir -p /vagrant/srcs/inventory-app
cat > /vagrant/srcs/inventory-app/.env << EOL
INVENTORY_API_PORT=${INVENTORY_API_PORT}
INVENTORY_API_HOST=${INVENTORY_API_HOST}
POSTGRES_INVENTORY_USER=${POSTGRES_INVENTORY_USER}
POSTGRES_INVENTORY_PASSWORD=${POSTGRES_INVENTORY_PASSWORD}
POSTGRES_INVENTORY_DB=${POSTGRES_INVENTORY_DB}
POSTGRES_INVENTORY_HOST=localhost
POSTGRES_INVENTORY_PORT=${POSTGRES_INVENTORY_PORT}
EOL

echo "Inventory API VM setup completed!"