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

Source:
[https://itnext.io/kubernetes-storage-part-1-nfs-complete-tutorial-75e6ac2a1f77]

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
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: manualy
    app.kubernetes.io/component: server
spec:
  containers:
    - name: alpine
      image: alpine:latest
      securityContext:
        runAsUser: 0
        allowPrivilegeEscalation: false      
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

## Method 2 — Connecting using the PersistentVolume resource

~~~yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-volume
  labels:
    storage.k8s.io/name: nfs
    storage.k8s.io/part-of: VCluster_Demo_NFS
    storage.k8s.io/created-by: mpatron
spec:
  accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
    - ReadWriteMany
  capacity:
    storage: 10Gi
  storageClassName: ""
  persistentVolumeReclaimPolicy: Recycle
  volumeMode: Filesystem
  nfs:
    server: node0
    path: /kubegfs
    readOnly: no
EOF
~~~

## Method 3 — Dynamic provisioning using StorageClass

~~~bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo update
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --create-namespace \
  --namespace nfs-provisioner \
  --set nfs.server=node0 \
  --set nfs.path=/kubegfs
~~~

~~~yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-test
  labels:
    storage.k8s.io/name: nfs
    storage.k8s.io/part-of: kubernetes-complete-reference
    storage.k8s.io/created-by: ssbostan
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
EOF
~~~

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
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: manualy
    app.kubernetes.io/component: server
spec:
  containers:
    - name: alpine
      image: alpine:latest
      securityContext:
        runAsUser: 0
        allowPrivilegeEscalation: false      
      command:
        - touch
        - /data/test
      volumeMounts:
        - name: nfs-volume
          mountPath: /data
  volumes:
    - name: n8n-pv-storage
      persistentVolumeClaim:
        claimName: nfs-pvc
EOF
~~~
  