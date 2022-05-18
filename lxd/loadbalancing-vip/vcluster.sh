#!/bin/bash
# set -x

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

NODES="node0 node1 node2 node3"

clusterprovision()
{
  # check if we have double-network-config profile or create one
  for ipnumber in {101..104}
  do
    lxc profile list | grep -qo double-network-config-$ipnumber || (lxc profile create double-network-config-$ipnumber && cat double-network-config-$ipnumber.yml | lxc profile edit double-network-config-$ipnumber)
  done
  echo
  ipnumber=101
  for NODE in $NODES
  do
    echo "==> [Provisionning] Bringing up $NODE"
    # lxc launch $IMAGE $NODE --profile double-network-config --vm
    lxc launch $IMAGE $NODE --profile double-network-config-$ipnumber
    ipnumber=$(($ipnumber+1))
    sleep 10
    # echo "==> Running provisioner script"
    cat instance-config.sh | lxc exec $NODE bash
    echo
    sleep 3
    echo "Waiting starting $NODE..."
    lxc exec $NODE -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'
    echo "$NODE started."

    lxc exec $NODE -- sh -c "mkdir -p /home/ubuntu/.ssh"
    lxc exec $NODE -- sh -c "chmod 700 /home/ubuntu/.ssh"
    cat ~/.ssh/id_rsa.pub | lxc exec $NODE -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
    lxc exec $NODE -- sh -c "chown ubuntu:ubuntu -R /home/ubuntu"
    lxc exec $NODE --  bash -c 'printf "ubuntu\nubuntu\n" | passwd ubuntu'
    lxc exec $NODE --  bash -c "sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config"
    lxc exec $NODE --  bash -c 'systemctl restart sshd.service'
  done
  
  NODES_IP=$(lxc list --format json | jq -r '.[] | .state.network.eth0.addresses | .[] | select (.family == "inet") | (.address)')
  for NODE_IP in $NODES_IP; do
    ssh-keygen -f ~/.ssh/known_hosts -R $NODE_IP
  done
  for ipnumber in {101..104}; do
    ssh-keygen -f ~/.ssh/known_hosts -R 192.168.88.$ipnumber
  done

  for NODE in $NODES; do
    lxc stop $NODE
    lxc network attach lxdbr1 $NODE eth1 eth1
    lxc start $NODE
  done
  echo "Test : ssh ubuntu@192.168.88.101 \"date && curl -I google.com\""
}

clusterdestroy()
{
  for NODE in $NODES; do
    echo "==> Destroying $NODE..."
    lxc list | grep -qo $NODE && lxc delete --force $NODE
  done
  for ipnumber in {101..104}; do
    lxc profile list | grep -qo double-network-config-$ipnumber && lxc profile delete double-network-config-$ipnumber
  done
  lxc profile list
  lxc list
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
