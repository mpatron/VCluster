# K0S

Date 15 mars 2022

## Source la documentation

- [Installation de k0s](https://docs.k0sproject.io/v1.23.3+k0s.1/install/)
- [Installation de traefik](https://traefik.io/blog/from-zero-to-hero-getting-started-with-k0s-and-traefik/)

## Installation des binaires

IL faut commencer par installer les binaires (k0s, k0sctl, kubectl et helm), puis mettre la completion automatique dans bash.

~~~bash
# Installation de k0s
curl -sSLf https://get.k0s.sh | sudo sh

# Installation de k0sctl
curl -LO "https://github.com/k0sproject/k0sctl/releases/download/$(curl -sSL https://api.github.com/repos/k0sproject/k0sctl/releases/latest|grep tag_name | cut -d '"' -f 4)/k0sctl-linux-x64"
sudo install -o root -g root -m 0755 k0sctl-linux-x64 /usr/local/bin/k0sctl

# Installation de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Installation de helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh
helm version

# Installation de la completion
mkdir ~/.kube && touch ~/.kube/config && sudo chown $USER:$USER ~/.kube/config && chmod 600 ~/.kube/config
echo 'source <(kubectl completion bash)' >>~/.bashrc && echo 'source <(helm  completion bash)' >>~/.bashrc && source <(kubectl completion bash) && source <(helm  completion bash)
source ~/.bashrc && echo 'source <(k0s completion bash)' >>~/.bashrc && source <(k0s completion bash) && echo 'source <(k0sctl completion bash)' >>~/.bashrc && source <(k0sctl completion bash)
tail -n 10 ~/.bashrc
~~~

## Installation de k0s en standalone

Création d'un fichier de configuration par défaut généré par k0s

~~~bash
sudo k0s config > /etc/k0s/k0s.yaml
# Editer /etc/k0s/k0s.yaml et mettre
# ...
#    storage:
#      create_default_storage_class: true
#      type: openebs_local_storage
#      ****
# ...
~~~

Mettre dans le fichier de configuration dans /etc/k0s/k0s.conf la configuration des extensions suivante. Ceci est pour avoir traefik et metallb d'installer. Définir le range des IP en fonction de votre vlan, ici 11 IP de 192.168.200.50 à 192.168.200.60.

~~~yaml
...
  extensions:
    storage:
      create_default_storage_class: true
      type: openebs_local_storage
    helm:
      repositories:
      - name: traefik
        url: https://helm.traefik.io/traefik
      - name: bitnami
        url: https://charts.bitnami.com/bitnami
      charts:
      - name: traefik
        chartname: traefik/traefik
        version: "10.3.2"
        namespace: default
      - name: metallb
        chartname: bitnami/metallb
        version: "2.5.4"
        namespace: default
        values: |2
          configInline:
            address-pools:
            - name: generic-cluster-pool
              protocol: layer2
              addresses:
              - 192.168.200.50-192.168.200.60
...
~~~

Lancement de l'installation en standalone :

~~~bash
mickael@mykube:~$ sudo k0s install controller --single --debug --config /etc/k0s/k0s.conf
mickael@mykube:~$ sudo k0s start
mickael@mykube:~$ sudo k0s status
Version: v1.23.3+k0s.0
Process ID: 3742
Role: controller
Workloads: true
SingleNode: true
mickael@mykube:~$ sudo k0s kubectl get nodes
NAME     STATUS     ROLES    AGE   VERSION
mykube   NotReady   <none>   5s    v1.23.3+k0s
mickael@mykube:~$ watch sudo k0s kubectl get pods -A
NAMESPACE     NAME                              READY   STATUS              RESTARTS   AGE
kube-system   kube-proxy-j6jc4                  1/1     Running             0          32s
kube-system   metrics-server-74c967d8d4-cmjtc   0/1     ContainerCreating   0          31s
kube-system   coredns-6d9f49dcbb-qsjhb          0/1     ContainerCreating   0          37s
kube-system   kube-router-6h9b8                 1/1     Running             0          32s
kube-system   metrics-server-74c967d8d4-cmjtc   0/1     Running             0          36s
kube-system   coredns-6d9f49dcbb-qsjhb          0/1     Running             0          45s
kube-system   coredns-6d9f49dcbb-qsjhb          1/1     Running             0          45s
~~~

Voilà, c'est fini, kubernetes fonctionne en standalone.

## Installation de k0s en cluster

Mise en place de la clef rsa, se connecter au node (vagrant ssh node0) puis

~~~bash
cd /vagrant/k0s
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
ansible-galaxy install -r requirements.yml --force
## ansible-galaxy collection install -r requirements.yml --force
## ansible-galaxy role install -r requirements.yml --force
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i ./inventory playbook_generate_rsa.yml
~~~

~~~bash
cd ~

# ============ Attention ============
# Il semble qu'il y ait un bug avec le DNS client systemd-resolved alors on le déactive
# Il empêche le téléchargement des pod system de kubernetes par abssence de résolution DNS
ansible all -i ./inventory -m raw -a "sudo systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved"
# ===================================

# k0sctl init > k0sctl.yaml
# Prendre le k0sctl.yml déjà fourni
k0sctl apply --config k0sctl.yaml
k0sctl kubeconfig > ~/.kube/config
watch kubectl get pods -A

# Pour tous supprimer
# k0sctl reset --config k0sctl.yaml
~~~

Voilà, c'est fini, kubernetes fonctionne en cluster.

## Installing Traefik and MetalLB

### Metallb

~~~bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install --namespace metallb-system --create-namespace metallb metallb/metallb
~~~

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
      - 192.168.121.110-192.168.121.120
EOF
~~~

Test de mettallb, pas la peine d'aller plus loin si ça ne fonctionne pas.

~~~bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/tutorial-2.yaml
kubectl get services
curl http://192.168.56.230
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/tutorial-2.yaml
~~~

### Traefik

~~~bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --set service.type=LoadBalancer
~~~

### Dashboard de traefik

Ajout du dashboard de traefik avec un fichier de configuration fourni : traefik-dashboard.yaml

~~~bash
k0s kubectl apply -f traefik-dashboard.yaml
watch k0s kubectl get all -A
# Test de la connection (ne pas oublier le / en fin d'url.)
curl http://192.168.200.50/dashboard/
~~~

## Création d'un son utilisateur admin

~~~bash
mkdir ~/.kube
sudo -u root k0s kubeconfig create --groups 'system:masters' $USER > $HOME/.kube/config
chmod 600 $HOME/.kube/config
sudo -u root k0s kubectl create clusterrolebinding --kubeconfig $HOME/.kube/config $USER-admin-binding --clusterrole=admin --user=$USER
mickael@mykube:~$ kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
mykube   Ready    control-plane   41m   v1.23.3+k0s
~~~


https://traefik.io/blog/from-zero-to-hero-getting-started-with-k0s-and-traefik/