# Création des volume de GlusterFS dans kubernetes

~~~bash
# Inside node0
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/glusterfs-endpoints.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/glusterfs-pod.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/glusterfs-service.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/gluster-pv.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/gluster-pvc.yaml
sudo kubectl exec -it glusterfs -- bash
# Inside pod
mount | grep gluster
~~~
