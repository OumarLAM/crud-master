# Define the Vagrant configuration
Vagrant.configure("2") do |config|
  # Load environment variables from .env file
  config.env.enable

  # Global VM configuration
  config.vm.box= "ubuntu/jammy64"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = "1024"
  end
  
  # Inventory APP VM
  config.vm.define "inventory-vm" do |inventory|
    inventory.vm.hostname = "inventory-vm"
    inventory.vm.network "public_network", bridge: "wlo1", ip: "192.168.100.201", netmask: "255.255.255.0", broadcast: "192.168.100.255"
    
    inventory.vm.provision "shell", path: "scripts/inventory.sh", env: ENV.to_hash
  end

  # Billing APP VM
  config.vm.define "billing-vm" do |billing|
    billing.vm.hostname = "billing-vm"
    billing.vm.network "public_network", bridge: "wlo1", ip: "192.168.100.202", netmask: "255.255.255.0", broadcast: "192.168.100.255"
    
    billing.vm.provision "shell", path: "scripts/billing.sh", env: ENV.to_hash
  end

  # API Gateway VM
  config.vm.define "gateway-vm" do |gateway|
    gateway.vm.hostname = "gateway-vm"
    gateway.vm.network "public_network", bridge: "wlo1", ip: "192.168.100.200", netmask: "255.255.255.0", broadcast: "192.168.100.255"
    
    gateway.vm.provision "shell", path: "scripts/gateway.sh", env: ENV.to_hash
  end

end
