# Création d'un cluster 4+1 noeuds avec vagrant

## Prosionning

Windows VirtualBox

~~~powershell
vagrant box update
vagrant plugin update
vagrant up --provision --provider virtualbox
vagrant destroy -f
vagrant global-status
~~~

Linux libvirt

~~~bash
vagrant box update
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin update
vagrant up --provision --provider=libvirt
~~~

Linux lxd

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
- [https://docs.ceph.com/projects/ceph-ansible/en/latest/](https://docs.ceph.com/projects/ceph-ansible/en/latest/)
