# LXD

~~~text
  _          _        
 | |__   ___| |_ __ _ 
 | '_ \ / _ \ __/ _` |
 | |_) |  __/ || (_| |
 |_.__/ \___|\__\__,_|
~~~

## Installation

~~~bash
sudo apt install lxc-utils
getent group lxd >/dev/null || sudo groupadd --system lxd
getent group lxd | grep -qwF "$USER" || sudo usermod -aG lxd "$USER" # adding current user as an example
# Vérification
lxc-checkconfig
lxc init ubuntu:24.04 ubuntu-vm --vm
lxc start ubuntu-vm --console
lxc exec ubuntu-vm -- bash -c 'date && ip a'
lxc exec ubuntu-vm bash

    node=ubuntu-vm
    echo "==> Creation du compte de developpement ubuntu"
    lxc exec $node -- sh -c "mkdir -p /home/ubuntu/.ssh"
    lxc exec $node -- sh -c "chmod 700 /home/ubuntu/.ssh"
    if [ -f ~/.ssh/id_rsa.pub ]; then
      cat ~/.ssh/id_rsa.pub | lxc exec $node -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
    fi    
    lxc exec $node -- sh -c "chown ubuntu:ubuntu -R /home/ubuntu"
    lxc exec $node -- bash -c 'printf "ubuntu\nubuntu\n" | passwd ubuntu'
    lxc exec $node -- bash -c "sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config"
    lxc exec $node -- bash -c 'systemctl restart sshd.service'
    
~~~

~~~bash
# https://lxdware.com/persistent-storage-on-lxd-instances/
lxc list --format json | jq -r '.[] | .state.network.eth0.addresses | .[] | select (.family == "inet") | (.address)'
# https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e
lxc image list images: | grep -i ubuntu | grep x86_64 | grep focal
# https://medium.com/geekculture/a-step-by-step-demo-on-kubernetes-cluster-creation-f183823c0411
~~~


# Pour Avoir community.general.lxd
ansible-galaxy collection install community.general

# Vérification
ansible-inventory --graph --vars
ansible all -m raw -a "sudo hwclock --hctosys && date"
ansible-galaxy install -r requirements.yml --force

cd ./lxd
./vcluster.sh destroy && ./vcluster.sh provision && ansible-playbook playbook.yml && ansible-playbook ../exemples/1-cluster-glusterfs/playbook_install.yml && ansible-playbook ../exemples/2-cluster-kubernetes/playbook_install.yml

## Debug
ansible node0 -m ansible.builtin.setup

## Shelll
lxc exec node0 -- bash
