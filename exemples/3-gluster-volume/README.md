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

## Method 1 — Connecting to NFS directly with Pod manifest

~~~yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test
  labels:
    app.kubernetes.io/name: alpine
    app.kubernetes.io/part-of: VCluster_Demo_NFS
    app.kubernetes.io/created-by: mpatron
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: manualy
    app.kubernetes.io/component: server
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command:
        - touch
        - /data/test
      volumeMounts:
        - name: nfs-volume
          mountPath: /data
  volumes:
    - name: nfs-volume
      nfs:
        server: node0
        path: /kubegfs
        readOnly: no
EOF
~~~
