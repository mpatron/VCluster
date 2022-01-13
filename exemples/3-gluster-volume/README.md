# Création des volume de GlusterFS dans kubernetes

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
