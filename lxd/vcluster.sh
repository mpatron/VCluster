#!/bin/bash
# set -x

IMAGE="ubuntu:20.04"

IMAGE="ubuntu:20.04"

usage()
{
  echo "Usage: $(basename $0) [provision|destroy]"
  exit 1
}
echo "debug: $0,$1,$2,$3,$4" $(dirname $0) $(basename $0)
if [ $# -ne 1 ] ; then
    usage
    exit 0
fi

# NODES="node0 node1 node2 node3"
NODES="node0 node1"

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
    # sleep 10
    # echo "==> Running provisioner script"
    # cat bootstrap-kube.sh | lxc exec $node bash
    # echo
    # sleep 3
    echo "Waiting starting $node..."
    lxc exec $node -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'
    echo "$node started."
    lxc exec $node -- sh -c "mkdir -p /home/ubuntu/.ssh"
    lxc exec $node -- sh -c "chmod 700 /home/ubuntu/.ssh"
    cat ~/.ssh/id_rsa.pub | lxc exec $node -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
    lxc exec $node -- sh -c "chown ubuntu:ubuntu -R /home/ubuntu"
    lxc exec $node --  bash -c 'printf "ubuntu\nubuntu\n" | passwd ubuntu'
    lxc exec $node --  bash -c "sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config"
    lxc exec $node --  bash -c 'systemctl restart sshd.service'
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
  *)
    usage
    ;;
esac
