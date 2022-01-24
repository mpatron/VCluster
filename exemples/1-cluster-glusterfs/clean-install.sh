#!/bin/bash

# Suppresion de glusterfs-7 et de ganesha-3 sur tous les noeuds
# for i in {0..4}; do vagrant ssh -c '. /vagrant/exemples/1-cluster-glusterfs/clean-install.sh' node${i}; done

sudo systemctl daemon-reload && sudo systemctl stop glusterd.service && sudo systemctl stop nfs-ganesha.service
sudo apt -y remove --purge glusterfs-common glusterfs-server glusterfs-client nfs-ganesha-gluster libntirpc*
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
sudo systemctl daemon-reload
sudo rm --verbose --force /etc/apt/sources.list.d/ppa_gluster_glusterfs_7_focal.list
sudo rm --verbose --force /etc/apt/sources.list.d/ppa_nfs_ganesha_libntirpc_3_0_focal.list
sudo rm --verbose --force /etc/apt/sources.list.d/ppa_nfs_ganesha_nfs_ganesha_3_0_focal.list
sudo apt update -y
