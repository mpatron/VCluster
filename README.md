# création d'un cluster avec vagrant

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
for i in {0..3}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
~~~

Exécuter une commande sur tous les noeux à partir du node0

~~~bash
ansible all -m raw -a "df -kh"
~~~

https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/
https://github.com/geerlingguy/ansible-role-kubernetes
https://github.com/geerlingguy/ansible-role-glusterfs
https://github.com/geerlingguy/ansible-for-devops/tree/master/kubernetes
