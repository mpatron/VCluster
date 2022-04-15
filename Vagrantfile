# -*- mode: ruby -*-
# vi: set ft=ruby :

# set http_proxy=http://login:pass@192.168.20.150:8080
# set https_proxy=%http_proxy%
# vagrant box add ubuntu/focal64
# vagrant up --provision --provider virtualbox

# ENV["LC_ALL"] = "fr_FR.UTF-8"
VM_COUNT = 3
VM_RAM = "6144" # 1024 2048 3072 4096 6144 8192
VM_CPU = 4
# VM
# IMAGE = "ubuntu/focal64" #20.04 LTS
IMAGE = "generic/ubuntu2004"
# LXC
# IMAGE = "hibox/focal64"
# IMAGE = "ubuntu/focal/cloud"

Vagrant.configure("2") do |config|
  
  # config.proxy.http     = "http://login:pass@192.168.20.150:8080"
  # config.proxy.https    = "http://login:pass@192.168.20.150:8080"
  # config.proxy.no_proxy = "localhost,127.0.0.1"
  puts "proxyconf..."
  if Vagrant.has_plugin?("vagrant-proxyconf")
    puts "find proxyconf plugin !"
    if ENV["http_proxy"]
      puts "http_proxy: " + ENV["http_proxy"]
      config.proxy.http = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      puts "https_proxy: " + ENV["https_proxy"]
      config.proxy.https = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      config.proxy.no_proxy = ENV["no_proxy"]
    end
  end

  config.vm.box = IMAGE
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600 # default=300s
  # config.ssh.insert_key = false
  # config.vm.synced_folder ".", "/vagrant"
  # config.vm.synced_folder ".", "/vagrant" , type: "virtualbox"  
  config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["vers=3,tcp"]  
  config.vm.provider :virtualbox do |vb|
    vb.cpus = VM_CPU
    vb.nested = true
    vb.memory = VM_RAM
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ['modifyvm', :id, '--graphicscontroller', 'vmsvga']
    vb.linked_clone = true
  end
  config.vm.provider :libvirt do |lbv|
    lbv.cpus = VM_CPU
    lbv.nested = true
    lbv.memory = VM_RAM
    lbv.storage :file, :type => 'qcow2', :size => "20G"
  end

  (0..VM_COUNT).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}.jobjects.net"
      node.vm.network :private_network, ip: "192.168.56.14#{i}"
      node.vm.provision "shell", run: "always", inline: <<-SHELL1
sudo sed -i -e "\\#PasswordAuthentication no# s#PasswordAuthentication no#PasswordAuthentication yes#g" /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo apt-get update -y && sudo apt-get install sshpass -y
SHELL1
    end
  end

 end
