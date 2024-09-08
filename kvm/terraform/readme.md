# KVM
  _  ____      ____  __ 
 | |/ /\ \    / /  \/  |
 | ' /  \ \  / /| \  / |
 |  <    \ \/ / | |\/| |
 | . \    \  /  | |  | |
 |_|\_\    \/   |_|  |_|
                        


~~~bash
apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin
~~~

https://www.server-world.info/en/note?os=Ubuntu_22.04&p=kvm&f=1


root@dlp:~# mkdir -p ~/Documents/VCluster/kvm/images
root@dlp:~# mkdir -p ~/Documents/VCluster/kvm/iso

curl --create-dirs -O --output-dir ~/Documents/VCluster/kvm/iso https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso

root@dlp:~# virt-install \
--name ubuntu2204 \
--ram 4096 \
--disk path=~/Documents/VCluster/kvm/images/ubuntu2204.img,size=20 \
--vcpus 2 \
--os-variant ubuntu22.04 \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location ~/Documents/VCluster/kvm/iso/ubuntu-22.04.1-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
--extra-args 'console=ttyS0,115200n8' 

virt-clone --original ubuntu2204 --name template --file ~/Documents/VCluster/kvm/images/template.img

virsh list --all

## Installation de terraform

~~~bash
TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
unzip terraform_${TER_VER}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
~~~

##  

~~~bash
$ vim main.tf
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  ## Configuration options
  uri = "qemu:///system"
  #alias = "server2"
  #uri   = "qemu+ssh://root@192.168.100.10/system"
}
...
~~~

~~~bash
mickael@deborah:~/Documents/VCluster/kvm$ virsh net-info --network default | grep Bridge | cut -d: -f2 | xargs
virbr0
mickael@deborah:~/Documents/VCluster/kvm$ ip address show dev virbr0 
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:9e:53:ee brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
~~~

~~~bash
sudo curl -O --output-dir /var/lib/libvirt/images/ https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
~~~


terraform init -upgrade
terraform apply

virsh list --all
virsh destroy test
virsh undefine test
