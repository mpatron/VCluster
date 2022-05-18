# Loadbalancing explain with LXD

## Creating instance


Creation du profile

~~~bash
lxc profile list | grep -qo double-network-config || (lxc profile create double-network-config && cat double-network-config.yml | lxc profile edit double-network-config)
lxc launch ubuntu:20.04 mycontainer  --profile double-network-config
~~~

Creation de l'instance

~~~bash
lxc profile list
lxc profile copy default privatepublicnetwork
lxc profile edit privatepublicnetwork
lxc launch ubuntu:20.04 mycontainer --profile privatepublicnetwork
lxc exec mycontainer -- sudo --user ubuntu --login
~~~

Netoyage

~~~bash
lxc stop mycontainer && lxc delete mycontainer 
lxc delete mycontainer --force
~~~


lxc network create lxdbr1
lxc stop node0
lxc network attach lxdbr1 mon_container eth1 eth1
lxc start node0
ip link set lxdbr1 up

## Sources

- [https://www.jbnet.fr/systeme/lxc/lxc-lxd-memo-de-configuration-ip-statique.html]
- [https://www.jbnet.fr/systeme/lxc/lxc-memo-pour-installer-minikube-dans-un-container-lxc-lxd.html]


curl -OL https://github.com/k0sproject/k0sctl/releases/download/v0.13.0-rc.2/k0sctl-linux-x64
sudo mv ./k0sctl-linux-x64 /usr/local/bin/k0sctl
sudo chmod +x /usr/local/bin/k0sctl
k0sctl apply --config k0sctl.yaml
k0sctl kubeconfig > lxdkubeconfig
mickael@deborah:~/Documents/VCluster/lxd/loadbalancing-vip$ kubectl --kubeconfig lxdkubeconfig get nodes,pods -A
NAME         STATUS   ROLES    AGE     VERSION
node/node1   Ready    <none>   3m38s   v1.23.6+k0s

NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   pod/coredns-8565977d9b-mqbcp          1/1     Running   0          3m44s
kube-system   pod/konnectivity-agent-nkmhf          1/1     Running   0          2m57s
kube-system   pod/kube-proxy-rfvfq                  1/1     Running   0          3m38s
kube-system   pod/kube-router-qb92m                 1/1     Running   0          3m38s
kube-system   pod/metrics-server-74c967d8d4-qnshd   1/1     Running   0          3m39s
mickael@deborah:~/Documents/VCluster/lxd/loadbalancing-vip$ curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl --kubeconfig lxdkubeconfig apply -f calico.yaml
mickael@deborah:~/Documents/VCluster/lxd/loadbalancing-vip$ kubectl --kubeconfig lxdkubeconfig get nodes,pods -A -o wide
NAME         STATUS   ROLES    AGE   VERSION       INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
node/node1   Ready    <none>   13m   v1.23.6+k0s   10.224.43.70    <none>        Ubuntu 20.04.4 LTS   5.13.0-41-generic   containerd://1.5.11
node/node2   Ready    <none>   59s   v1.23.6+k0s   10.224.43.119   <none>        Ubuntu 20.04.4 LTS   5.13.0-41-generic   containerd://1.5.11

NAMESPACE     NAME                                          READY   STATUS                 RESTARTS   AGE     IP              NODE    NOMINATED NODE   READINESS GATES
kube-system   pod/calico-kube-controllers-6b77fff45-g9l5c   1/1     Running                0          3m38s   10.244.0.5      node1   <none>           <none>
kube-system   pod/calico-node-8kc9p                         0/1     CreateContainerError   0          3m38s   10.224.43.70    node1   <none>           <none>
kube-system   pod/calico-node-wmjnz                         0/1     PodInitializing        0          59s     10.224.43.119   node2   <none>           <none>
kube-system   pod/coredns-8565977d9b-mqbcp                  1/1     Running                0          13m     10.244.0.3      node1   <none>           <none>
kube-system   pod/coredns-8565977d9b-w9dwz                  0/1     ContainerCreating      0          57s     <none>          node1   <none>           <none>
kube-system   pod/konnectivity-agent-nkmhf                  1/1     Running                0          13m     10.244.0.4      node1   <none>           <none>
kube-system   pod/konnectivity-agent-z6x94                  0/1     ContainerCreating      0          18s     <none>          node2   <none>           <none>
kube-system   pod/kube-proxy-qvpqs                          1/1     Running                0          59s     10.224.43.119   node2   <none>           <none>
kube-system   pod/kube-proxy-rfvfq                          1/1     Running                0          13m     10.224.43.70    node1   <none>           <none>
kube-system   pod/kube-router-qb92m                         1/1     Running                0          13m     10.224.43.70    node1   <none>           <none>
kube-system   pod/kube-router-xq4tf                         0/1     Init:1/2               0          59s     10.224.43.119   node2   <none>           <none>
kube-system   pod/metrics-server-74c967d8d4-qnshd           1/1     Running                0          13m     10.244.0.2      node1   <none>           <none>