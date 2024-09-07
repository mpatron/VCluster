#!/bin/bash
set -x
# This script has been tested on Ubuntu 24.04
# For other versions of Ubuntu, you might need some tweaking
# https://github.com/justmeandopensource/kubernetes/blob/master/lxd-provisioning/bootstrap-kube.sh

echo "[TASK 1] Install containerd runtime"
apt update -qq >/dev/null 2>&1
apt install -qq -y containerd ca-certificates apt-transport-https curl gnupg lsb-release software-properties-common >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "[TASK 2] Add apt repo for kubernetes"
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
# apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update

echo "[TASK 3] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm kubelet kubectl >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl
# apt install -qq -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00 >/dev/null 2>&1
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/default/kubelet
# /var/lib/kubelet/config.yaml
systemctl restart kubelet

echo "[TASK 4] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload ssh

echo "[TASK 5] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 6] Install additional packages"
apt install -qq -y net-tools >/dev/null 2>&1

# Hack required to provision K8s v1.15+ in LXC containers
mknod /dev/kmsg c 1 11
echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.local
chmod +x /etc/rc.local

#######################################
# To be executed only on master nodes #
#######################################
if [[ $(hostname) =~ .*master.* ]]
then
  echo "source /etc/bash_completion" >> /root/.bashrc # Work arround bug : https://stackoverflow.com/questions/50406142/kubectl-bash-completion-doesnt-work-in-ubuntu-docker-container
  echo "source <(kubectl completion bash)" >> /root/.bashrc

  echo "[TASK 7] Pull required containers"
  kubeadm config images pull >/dev/null 2>&1

  echo "[TASK 8] Initialize Kubernetes Cluster"
  # Pour supprimer [WARNING SystemVerification]: failed to parse kernel config: unable to load kernel module: “configs”, output: “modprobe: FATAL: Module configs not found in directory /lib/modules/5.4.0–77-generic, dans les --ignore-preflight-errors
  apt-get install -yqq linux-image-$(uname -r)
  kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log 2>&1

  echo "[TASK 9] Copy kube admin config to root user .kube directory"
  mkdir /root/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config

  # echo "[TASK 10] Deploy Flannel network"
  # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > /dev/null 2>&1

  echo "[TASK 10] Deploy Calico network"
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml >/dev/null
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml >/dev/null

  echo "[TASK 11] Generate and save cluster join command to /root/joincluster.sh"
  joinCommand=$(kubeadm token create --print-join-command 2>/dev/null) 
  echo "$joinCommand --ignore-preflight-errors=all" > /root/joincluster.sh
fi

#######################################
# To be executed only on worker nodes #
#######################################

if [[ $(hostname) =~ .*worker.* ]]
then
  echo "[TASK 7] Join node to Kubernetes Cluster"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master0.lxd:/root/joincluster.sh /root/joincluster.sh 2>/tmp/joincluster.log
  bash /root/joincluster.sh >> /tmp/joincluster.log 2>&1
fi
