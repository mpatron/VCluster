# Création d'un cluster 4+1 noeuds avec vagrant

## Prosionning

Windows VirtualBox

~~~powershell
vagrant plugin update
vagrant up --provision --provider virtualbox
vagrant destroy -f
vagrant global-status
~~~

Linux libvirt

~~~bash
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin update
vagrant up --provision --provider=libvirt
~~~

Linux lxc

~~~bash
sudo apt-get install lxc-utils lxc-templates
vagrant plugin install vagrant-lxc
vagrant plugin update
vagrant up --provision --provider=lxc
# ajouter lxc__bridge_name: 'vlxcbr1' dans Vagrantfile
# node.vm.network "private_network", ip: "192.168.56.14#{i}"#, lxc__bridge_name: 'vlxcbr1'
~~~

~~~bash
vagrant plugin install vagrant-lxd
vagrant plugin update
lxc config get core.https_address
# vide alors faire
lxc config set core.https_address 127.0.0.1
lxc config trust add /home/$USER/.vagrant.d/data/lxd/client.crt

vagrant up --provision --provider=lxd
# lxc list --format json | jq -r '.[] | .state.network.eth0.addresses | .[] | select (.family == "inet") | .address'
~~~


## Commandes utiles

Visialisation de l'inventory sur le node0

~~~bash
cat /etc/ansible/hosts | grep -v '^\s*$\|^\s*\#'
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "node${i}"; done
~~~

Exécuter une commande sur tous les noeux à partir du node0

~~~bash
ansible all -m raw -a "df -kh"
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
~~~

## Kubernetes status

systemctl daemon-reload && systemctl status kubelet


# See documentation:

- [Installation de GlusterFS](exemples/1-cluster-glusterfs/README.md)
- [Installation de Kubernetes](exemples/2-cluster-kubernetes/README.md)
- [Installation des volumes GlusterFS et NFS dans kubernetes](exemples/3-gluster-volume/README.md)
