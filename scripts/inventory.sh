#!/bin/bash

# Update and install dependencies
apt-get update
apt-get install -y ca-certificates curl postgresql gnupg lsb-release

echo "✅ Successfully installed dependencies"

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

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_INVENTORY_DB};"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_INVENTORY_PASSWORD}'"

sed -i -E "s/\b(peer|trust)\b/md5/g" /etc/postgresql/14/main/pg_hba.conf
sudo systemctl restart postgresql

# Install Node.js app dependencies and start with PM2
cp -r /vagrant/srcs/inventory-app/ /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/inventory-app

su - vagrant <<EOF
cd /home/vagrant/inventory-app
npm install
sudo pm2 start 'node server.js' --name 'inventory-api'
EOF