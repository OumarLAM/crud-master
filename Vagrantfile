# Define the Vagrant configuration
Vagrant.configure("2") do |config|
  # Load environment variables from .env file
  env = {}
  File.readlines('.env').each do |line|
    if line.match(/^[A-Za-z0-9_]+=.+$/)
      key, value = line.split('=', 2)
      env[key] = value.strip
    end
  end

  # Common configuration
  config.vm.box= "ubuntu/focal64"
  
  # API Gateway VM
  config.vm.define "gateway-vm" do |gateway|
    gateway.vm.hostname = "gateway-vm"
    gateway.vm.network "private_network", ip: '192.168.56.10' # handle VM-to-VM communication
    gateway.vm.network "forwarded_port", guest: 3000, host: 3000   # handle host-to-VM communication
    
    gateway.vm.provider "virtualbox" do |vb|
      vb.cpus = 1
      vb.memory = "1024"
    end
    
    gateway.vm.provision "shell", path: "scripts/gateway-setup.sh", env: env
  end

  # Inventory API VM
  config.vm.define "inventory-vm" do |inventory|
    inventory.vm.hostname = "inventory-vm"
    inventory.vm.network "private_network", ip: '192.168.56.11'
    inventory.vm.network "forwarded_port", guest: 8080, host: 8080
    inventory.vm.network "forwarded_port", guest: 5432, host: 5433 # 5432 (PostgreSQL)

    inventory.vm.provider "virtualbox" do |vb|
      vb.cpus = 1
      vb.memory = "1024"
    end

    inventory.vm.provision "shell", path: "scripts/inventory-setup.sh", env: env
  end

  # Billing API VM
  config.vm.define "billing-vm" do |billing|
    billing.vm.hostname = "billing-vm"
    billing.vm.network "private_network", ip: '192.168.56.12'
    billing.vm.network "forwarded_port", guest: 8081, host: 8081
    billing.vm.network "forwarded_port", guest: 5432, host: 5434
    billing.vm.network "forwarded_port", guest: 5672, host: 5673  # (RabbitMQ)
    billing.vm.network "forwarded_port", guest: 15672, host: 15673  # (RabbitMQ management)
  
    billing.vm.provider "virtualbox" do |vb|
      vb.cpus = 1
      vb.memory = "1536"
    end

    billing.vm.provision "shell", path: "scripts/billing-setup.sh", env: env
  end

end
