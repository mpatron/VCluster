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
