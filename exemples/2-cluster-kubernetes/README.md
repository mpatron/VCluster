# Installation de Kubernetes

~~~bash
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done

ansible-galaxy install -r requirements.yml --force
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i ./inventory playbook_install.yml

# Ce qui suit est fait pas le playbook component
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

mkdir -p ~/.kube && sudo sh -c "cat /root/.kube/config > /home/vagrant/.kube/config" && sudo chown $USER:$USER ~/.kube/config && echo 'source <(kubectl completion bash)' >>~/.bashrc && echo 'source <(helm  completion bash)' >>~/.bashrc && source <(kubectl completion bash) && source <(helm  completion bash)
~~~

## Challenge de migration

Traefik 1.7.26 (28/07/20)->v1.7.34 (10/12/21)

- [https://github.com/traefik/traefik/blob/v1.7/examples/k8s/traefik-deployment.yaml]
- [https://doc.traefik.io/traefik/migration/v1-to-v2/]

Kubernetes 1.18.8 ()-> 1.18.20-00

## Configuration de mettallb

~~~bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.56.230-192.168.56.250
EOF
~~~

## Test

~~~bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/tutorial-2.yaml
kubectl get services
curl http://192.168.56.230
~~~

## Upgrade

~~~bash
apt list --upgradable
apt-get install -qy kubeadm=1.20.14-00
sudo apt-get install -qy kubelet=1.20.14-00 kubectl=1.20.14-00 kubeadm=1.20.14-00
kubeadm upgrade plan
kubeadm upgrade node

sudo apt-mark unhold kubeadm kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubeadm=1.20.14-00 kubelet=1.20.14-00 kubectl=1.20.14-00 && sudo apt-mark hold kubeadm kubelet kubectl

sudo apt-mark hold kubeadm kubelet kubectl
sudo apt-mark showhold

root@node0:~# kubectl -n kube-system get cm kubeadm-config -o yaml
apiVersion: v1
data:
  ClusterConfiguration: |
    apiServer:
      extraArgs:
        authorization-mode: Node,RBAC
      timeoutForControlPlane: 4m0s
    apiVersion: kubeadm.k8s.io/v1beta2
    certificatesDir: /etc/kubernetes/pki
    clusterName: kubernetes
    controllerManager: {}
    dns:
      type: CoreDNS
    etcd:
      local:
        dataDir: /var/lib/etcd
    imageRepository: k8s.gcr.io
    kind: ClusterConfiguration
    kubernetesVersion: v1.20.14
    networking:
      dnsDomain: cluster.local
      podSubnet: 10.244.0.0/16
      serviceSubnet: 10.96.0.0/12
    scheduler: {}
  ClusterStatus: |
    apiEndpoints:
      node0:
        advertiseAddress: 192.168.56.140
        bindPort: 6443
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterStatus
kind: ConfigMap
metadata:
  creationTimestamp: "2021-12-30T14:43:51Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:ClusterConfiguration: {}
        f:ClusterStatus: {}
    manager: kubeadm
    operation: Update
    time: "2021-12-30T14:43:51Z"
  name: kubeadm-config
  namespace: kube-system
  resourceVersion: "209"
  uid: c81e767a-bff7-4525-bb28-fd69c1a1c840
~~~

[https://v1-21.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/]

~~~bash
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
sudo apt update
sudo apt-cache madison kubeadm
# Cible 1.21.8-00
vagrant@node1:~$ apt-cache madison kubeadm
   kubeadm |  1.23.1-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.23.0-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.5-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.4-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.3-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.2-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.1-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.22.0-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.8-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.7-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.6-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.5-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.4-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.3-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.2-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.1-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.21.0-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages

sudo apt-mark unhold kubeadm kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubeadm=1.20.14-00 kubelet=1.20.14-00 kubectl=1.20.14-00 && sudo apt-mark hold kubeadm kubelet kubectl

# replace x in 1.21.x-00 with the latest patch version
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.21.8-00 && \
apt-mark hold kubeadm

# since apt-get version 1.1 you can also use the following method
apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.21.x-00
~~~

~~~text
root@node0:~# kubeadm upgrade plan
...
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT        TARGET
kubelet     3 x v1.20.14   v1.21.8

Upgrade to the latest stable version:

COMPONENT                 CURRENT    TARGET
kube-apiserver            v1.20.14   v1.21.8
kube-controller-manager   v1.20.14   v1.21.8
kube-scheduler            v1.20.14   v1.21.8
kube-proxy                v1.20.14   v1.21.8
CoreDNS                   1.7.0      v1.8.0
etcd                      3.4.13-0   3.4.13-0

You can now apply the upgrade by executing the following command:

...
~~~

~~~bash
root@node0:~# kubeadm upgrade apply v1.21.8
...
# sur chaque worker :
KVERSION=1.21.8-00
sudo apt-mark unhold kubeadm kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubeadm=${KVERSION} kubelet=${KVERSION} kubectl=${KVERSION} && sudo apt-mark hold kubeadm kubelet kubectl
sudo kubeadm upgrade node
sudo systemctl restart kubelet
~~~

## Components

Prérequis, il faut que le lanceur de ansible ait pip3 et le module pip kubernetes

~~~bash
sudo apt install python3-pip
pip3 install kubernetes
~~~

## Docker Repository

~~~bash
DOCKER_REGISTRY_SERVER=docker.io
DOCKER_USER=Type your dockerhub username, same as when you `docker login`
DOCKER_EMAIL=Type your dockerhub email, same as when you `docker login`
DOCKER_PASSWORD=Type your dockerhub pw, same as when you `docker login`

kubectl create secret docker-registry myregistrykey \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL
~~~

## Sources

- [kubernetes-cluster-using-ansible](https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/)
- [ansible-role-kubernetes](https://github.com/geerlingguy/ansible-role-kubernetes)
- [ansible-role-glusterfs](https://github.com/geerlingguy/ansible-role-glusterfs)
- [ansible-for-devops](https://github.com/geerlingguy/ansible-for-devops/tree/master/kubernetes)
- [Old migration](https://platform9.com/blog/kubernetes-upgrade-the-definitive-guide-to-do-it-yourself/)
- [Module ansible kubernetes core](https://github.com/ansible-collections/kubernetes.core/tree/main/docs)
