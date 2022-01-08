# Création d'un cluster 4+1 noeuds avec vagrant

## Prosionning

~~~powershell
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
~~~

## myLib documentation

See documentation:

- [Installation de GlusterFS](exemples/1-glusterfs/README.md)
- [Installation de Kubernetes](exemples/2-kubernetes/README.md)
