# Installation de GlusterFS

~~~bash
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
ansible-galaxy install -r requirements.yml -p ./roles
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i ./inventory install_glusterfs.yml
vagrant ssh -c "sudo gluster volume info" node0
~~~

## Supression d'un volume glusterFS

~~~bash
sudo gluster volume stop <volume name>
sudo gluster volume delete <volume name>
~~~

## Test avec kubernetes

~~~bash
# Inside node0
sudo kubectl apply -f /vagrant/exemples/1-glusterfs/files/glusterfs-endpoints.yaml
sudo kubectl apply -f /vagrant/exemples/1-glusterfs/files/glusterfs-pod.yaml
sudo kubectl apply -f /vagrant/exemples/1-glusterfs/files/glusterfs-service.yaml
sudo kubectl apply -f /vagrant/exemples/1-glusterfs/files/gluster-pv.yaml
sudo kubectl apply -f /vagrant/exemples/1-glusterfs/files/gluster-pvc.yaml
sudo kubectl exec -it glusterfs -- bash
# Inside pod
mount | grep gluster
~~~
