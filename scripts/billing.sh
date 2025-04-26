#!/bin/bash

# Update and install dependencies
apt-get update
apt-get install -y curl postgresql rabbitmq-server
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
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_BILLING_DB};"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_BILLING_PASSWORD}'"

sed -i -E "s/\b(peer|trust)\b/md5/g" /etc/postgresql/14/main/pg_hba.conf
sudo systemctl restart postgresql
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_BILLING_DB} TO ${POSTGRES_BILLING_USER};"

# Configure RabbitMQ
rabbitmq-plugins enable rabbitmq_management
rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASSWORD}
rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
rabbitmqctl set_permissions -p / ${RABBITMQ_USER} ".*" ".*" ".*"
systemctl restart rabbitmq-server

# Install Node.js app dependencies and start with PM2
cp -r /vagrant/srcs/billing-app/ /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/billing-app

su - vagrant <<EOF
cd /home/vagrant/billing-app
npm install
sudo pm2 start 'node server.js' --name 'billing-api'
EOF