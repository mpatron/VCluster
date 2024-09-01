#!/bin/bash
# set -x

IMAGE="ubuntu:24.04"

usage()
{
  echo "Usage: $(basename $0) [provision|destroy|status]"
  exit 1
}
echo "debug: $0,$1,$2,$3,$4" $(dirname $0) $(basename $0)
if [ $# -ne 1 ] ; then
    usage
    exit 0
fi

# NODES="node0 node1 node2 node3"
NODES="node0 node1"
# NODES="kmaster0 worker1 worker2"

clusterprovision()
{
  # check if we have node-profile profile or create one
  lxc profile list | grep -qo node-profile || (lxc profile create node-profile && cat node-profile-config | lxc profile edit node-profile)
  echo
  for node in $NODES
  do
    echo "==> Bringing up $node"
    # lxc launch $IMAGE $node --profile node-profile --vm
    lxc launch $IMAGE $node --profile node-profile
    sleep 10
    echo "==> Waiting starting $node ..."
    lxc exec $node -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'
    echo "==> ... $node started."
    
    echo "==> Installation des certificats CA supplémentaire"
    lxc exec $node -- sh -c "apt update >/dev/null 2>&1"
    lxc exec $node -- sh -c "apt install -yqq ca-certificates apt-transport-https >/dev/null 2>&1"
    lxc exec $node -- sh -c "mkdir -p /usr/share/ca-certificates/extra/"
    PRIVATESCA="mycompany1-CA.crt mycompany2-CA.crt mycompany3-CA.crt"
    for PRIVATECA in $PRIVATESCA; do
      if [ -f $PRIVATECA ]; then
        lxc file push $PRIVATECA $node/usr/share/ca-certificates/extra/$PRIVATECA
        lxc exec $node -- sh -c "echo 'extra/$PRIVATECA' >> /etc/ca-certificates.conf"
      fi
    done
    lxc exec $node -- sh -c "update-ca-certificates"

    echo "==> Creation du compte de developpement ubuntu"
    lxc exec $node -- sh -c "mkdir -p /home/ubuntu/.ssh"
    lxc exec $node -- sh -c "chmod 700 /home/ubuntu/.ssh"
    if [ -f ~/.ssh/id_rsa.pub ]; then
      cat ~/.ssh/id_rsa.pub | lxc exec $node -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
    fi    
    lxc exec $node -- sh -c "chown ubuntu:ubuntu -R /home/ubuntu"
    lxc exec $node -- bash -c 'printf "ubuntu\nubuntu\n" | passwd ubuntu'
    lxc exec $node -- bash -c "sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config"
    lxc exec $node -- bash -c 'systemctl restart sshd.service'
  done

  for node in $NODES
  do
    echo "==> Running provisioner script"
    cat bootstrap-kube.sh | lxc exec $node bash
    echo
    sleep 3
  done
  
  NODES_IP=$(lxc list --format json | jq -r '.[] | .state.network.eth0.addresses | .[] | select (.family == "inet") | (.address)')
  for NODE_IP in $NODES_IP; do
    ssh-keygen -f ~/.ssh/known_hosts -R $NODE_IP
  done
}

clusterdestroy()
{
  for node in $NODES
  do
    echo "==> Destroying $node..."
    lxc delete --force $node
  done
  lxc profile delete node-profile
  clusterstatus
}

clusterstatus()
{
  lxc list
  lxc profile list
}

case "$1" in
  provision)
    echo -e "\nProvisioning VCluster...\n"
    clusterprovision
    ;;
  destroy)
    echo -e "\nDestroying VCluster...\n"
    clusterdestroy
    ;;
  status)
    echo -e "\nStatus VCluster...\n"
    clusterstatus
    ;;
  *)
    usage
    ;;
esac
