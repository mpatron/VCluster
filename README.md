# création d'un cluster avec vagrant

## Prosionning

~~~powershell
vagrant up --provision --provider virtualbox
~~~

## Commandes utiles

Visialisation de l'inventory sur le node0

~~~bash
cat /etc/ansible/hosts | grep -v '^\s*$\|^\s*\#'
~~~

Exécuter une commande sur tous les noeux à partir du node0

~~~bash
ansible all -m raw -a "df -kh"
~~~
