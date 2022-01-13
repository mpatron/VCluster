# Installation de GlusterFS

~~~bash
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
ansible-galaxy install -r requirements.yml -p ./roles
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i ./inventory install_glusterfs.yml
~~~

## Supression d'un volume glusterFS

~~~bash
sudo gluster volume stop <volume name>
sudo gluster volume delete <volume name>
~~~

## Test de GlusterFS

~~~bash
vagrant ssh -c "sudo gluster volume info" node0
~~~
