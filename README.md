# Création d'un cluster 4+1 noeuds avec vagrant

## Prosionning

### Windows VirtualBox

~~~powershell
vagrant box update
vagrant plugin update
vagrant up --provision --provider virtualbox
vagrant destroy -f
vagrant global-status
~~~

### Linux libvirt

#### Installation de KVM

~~~bash
sudo apt install cpu-checker
mpatron@mario:~/VCluster$ kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
~~~

#### Installation de Vagrant

~~~bash
sudo apt install vagrant
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin update
mpatron@mario:~/VCluster$ vagrant plugin list
vagrant-libvirt (0.0.45, system)
vagrant-mutate (1.2.0, global)
~~~

~~~bash
vagrant box update
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin update
vagrant up --provision --provider=libvirt
~~~

## Linux lxd

~~~bash
cd lxd
./vcluster provision
~~~


## Commandes utiles

Visialisation de l'inventory sur le node0

~~~bash
cat /etc/ansible/hosts | grep -v '^\s*$\|^\s*\#'
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "node${i}"; done
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-galaxy install -r requirements.yml --force
ansible-playbook -i ./inventory provision.yml
~~~

Exécuter une commande sur tous les noeux à partir du node0

~~~bash
ansible all -m raw -a "df -kh"
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
~~~

## Kubernetes status

~~~bash
# Dans un noeud
systemctl daemon-reload && systemctl status kubelet

# Sur un le code VCluster
cd exemples/2-cluster-kubernetes/
ansible-playbook -i ./inventory playbook_install.yml 
ansible-playbook -i ./inventory playbook_install_console_tools.yml 

git clone --single-branch --branch v1.9.0 https://github.com/rook/rook.git
cd ~/rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
kubectl -n rook-ceph rollout status deploy/rook-ceph-tools
# Puis
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
# Et Faire
ceph status
~~~

# See documentation:

- [Installation de GlusterFS](exemples/1-cluster-glusterfs/README.md)
- [Installation de Kubernetes](exemples/2-cluster-kubernetes/README.md)
- [Installation des volumes GlusterFS et NFS dans kubernetes](exemples/3-gluster-volume/README.md)
- [https://docs.ceph.com/projects/ceph-ansible/en/latest/](https://docs.ceph.com/projects/ceph-ansible/en/latest/)
- [https://ubuntu.com/blog/kvm-hyphervisor](https://ubuntu.com/blog/kvm-hyphervisor)
