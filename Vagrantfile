# -*- mode: ruby -*-
# vi: set ft=ruby :

# set http_proxy=http://login:pass@192.168.20.150:8080
# set https_proxy=%http_proxy%
# vagrant box add ubuntu/focal64
# vagrant up --provision --provider virtualbox

ENV["LC_ALL"] = "fr_FR.UTF-8"
VM_COUNT = 4
VM_RAM = "2048" # 1024 2048 4096 8192
VM_CPU = 2
IMAGE = "ubuntu/focal64" #20.04 LTS

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

  (1..VM_COUNT).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}.jobjects.net"

      node.vm.box = IMAGE
      node.vm.boot_timeout = 60
      node.vm.provider "virtualbox" do |vb|
        vb.cpus = VM_CPU    
        vb.memory = VM_RAM
        vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
      end

      node.vm.network "private_network", ip: "192.168.56.14#{i}"
      node.vm.provision "shell", run: "always", inline: <<-SHELL1
        sudo apt update && sudo apt install sshpass
        sudo sed -i -e "\\#PasswordAuthentication no# s#PasswordAuthentication no#PasswordAuthentication yes#g" /etc/ssh/sshd_config
        sudo systemctl restart sshd
      SHELL1
    end
  end

  config.vm.define 'node0' do |machine|
    machine.vm.hostname = "node0.jobjects.net"

    machine.vm.box = IMAGE
    machine.vm.boot_timeout = 60
    machine.vm.provider "virtualbox" do |vb|
      vb.cpus = VM_CPU    
      vb.memory = VM_RAM
      vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    end

    machine.vm.network "private_network", ip: "192.168.56.140"
    # Workaround, sous windows /vagrant/ansible.cfg est r/w et il faut que ansible.cfg soit ro
    machine.vm.provision "shell", inline: "sudo mkdir -p /etc/ansible && sudo cat /vagrant/ansible.cfg > /etc/ansible/ansible.cfg", run: "always"
    machine.vm.provision "shell", inline: "sudo sh -c 'cat /vagrant/inventory.txt > /etc/ansible/hosts'", run: "always"
    machine.vm.provision "shell", inline: "sudo apt update && sudo apt install sshpass", run: "always"
    machine.vm.provision :ansible_local do |ansible|
      ansible.playbook       = "provision.yml"
      ansible.verbose        = true
      # ansible.install        = true # default=true
      ansible.compatibility_mode = "auto"
      ansible.limit          = "all" # or only "nodes" group, etc.
      ansible.inventory_path = "inventory.txt"
    end

  end
 end
