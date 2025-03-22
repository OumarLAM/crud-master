#!/bin/bash
set -e

echo "Setting up Billing API VM..."

# Update package lists and install dependencies
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg2 git postgresql postgresql-contrib apt-transport-https
echo "✅ Successfully installed dependencies"

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

# Install RabbitMQ
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null

## Add apt repositories maintained by Team RabbitMQ
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main

## Provides RabbitMQ
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
EOF

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing

# Start PostgreSQL and enable at boot
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Start RabbitMQ and enable at boot
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Configure RabbitMQ
sudo rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASSWORD} || echo "User already exists"
sudo rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
sudo rabbitmqctl set_permissions -p / ${RABBITMQ_USER} ".*" ".*" ".*"

# Create database and user
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${POSTGRES_BILLING_USER}'" | grep -q 1 ||
sudo -u postgres psql -c "CREATE USER ${POSTGRES_BILLING_USER} WITH PASSWORD '${POSTGRES_BILLING_PASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_BILLING_DB};"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_BILLING_DB} TO ${POSTGRES_BILLING_USER};"

# Configure PostgreSQL to accept remote connections
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf
service postgresql restart

# Create .env file in the Billing API directory
mkdir -p /vagrant/srcs/billing-app
cat > /vagrant/srcs/billing-app/.env << EOL
BILLING_API_PORT=${BILLING_API_PORT}
BILLING_API_HOST=${BILLING_API_HOST}
POSTGRES_BILLING_USER=${POSTGRES_BILLING_USER}
POSTGRES_BILLING_PASSWORD=${POSTGRES_BILLING_PASSWORD}
POSTGRES_BILLING_DB=${POSTGRES_BILLING_DB}
POSTGRES_BILLING_HOST=localhost
POSTGRES_BILLING_PORT=${POSTGRES_BILLING_PORT}
RABBITMQ_HOST=${RABBITMQ_HOST}
RABBITMQ_PORT=${RABBITMQ_PORT}
RABBITMQ_USER=${RABBITMQ_USER}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
RABBITMQ_URL=${RABBITMQ_URL}
RABBITMQ_QUEUE=${RABBITMQ_QUEUE}
EOL

# Navigate to the app directory && Install dependencies
cd /vagrant/srcs/billing-app && npm install
if [ $? -eq 0 ]; then
# Start the application with PM2
    pm2 start server.js --name "billing-api" --time
    echo "✅ Billing API started successfully with PM2"
else
    echo "❌ Failed to install npm dependencies"
    exit 1
fi

echo "Billing API VM setup completed!"