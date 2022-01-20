# Création d'un cluster 4+1 noeuds avec vagrant

## Prosionning

~~~powershell
vagrant plugin update 
vagrant up --provision --provider virtualbox
vagrant destroy -f
vagrant global-status
~~~

## Commandes utiles

Visialisation de l'inventory sur le node0

~~~bash
cat /etc/ansible/hosts | grep -v '^\s*$\|^\s*\#'
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
~~~

Exécuter une commande sur tous les noeux à partir du node0

~~~bash
ansible all -m raw -a "df -kh"
ansible gluster -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
~~~

## myLib documentation

See documentation:

- [Installation de GlusterFS](exemples/1-cluster-glusterfs/README.md)
- [Installation de Kubernetes](exemples/2-cluster-kubernetes/README.md)
- [Installation des volumes GlusterFS et NFS dans kubernetes](exemples/3-gluster-volume/README.md)
