# Création des volume de GlusterFS dans kubernetes

~~~bash
# Inside node0
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/1-glusterfs-endpoints.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/2-glusterfs-service.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/3-gluster-pv.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/4-gluster-pvc.yaml
sudo kubectl apply -f /vagrant/exemples/3-gluster-volume/files/5-exemple-glusterfs-pod.yaml
sudo kubectl exec -it glusterfs -- bash
# Inside pod
mount | grep gluster
~~~
