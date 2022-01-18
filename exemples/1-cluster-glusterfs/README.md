# Installation de GlusterFS

~~~bash
for i in {0..4}; do ssh-keygen -f ~/.ssh/known_hosts -R "192.168.56.14${i}"; done
ansible-galaxy install -r requirements.yml -p ./roles
ansible all -i ./inventory -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i ./inventory playbook_install.yml
~~~

## Supression d'un volume glusterFS

~~~bash
sudo gluster volume stop <volume name>
sudo gluster volume delete <volume name>
~~~

## Test de GlusterFS

~~~bash
vagrant ssh -c "sudo gluster volume info" node0
~~~

~~~bash

sudo gluster volume get kubegfs nfs.disable
# On doit voir "on"
sudo apt -y install nfs-ganesha-gluster
sudo systemctl daemon-reload
sudo mv /etc/ganesha/ganesha.conf /etc/ganesha/ganesha.conf.init

# create new
cat << EOF >/etc/ganesha/ganesha.conf
NFS_CORE_PARAM {
    # possible to mount with NFSv3 to NFSv4 Pseudo path
    mount_path_pseudo = true;
    # NFS protocol
    Protocols = 3,4;
}
EXPORT_DEFAULTS {
    # default access mode
    Access_Type = RW;
}
EXPORT {
    # uniq ID
    Export_Id = 101;
    # mount path of Gluster Volume
    Path = "/kubegfs";
    FSAL {
      # any name
      name = GLUSTER;
      # hostname or IP address of this Node
      hostname="192.168.56.140";
      # Gluster volume name
      volume="kubegfs";
      enable_upcall = true;
      Transport = tcp; # tcp or rdma
    }
    # config for root Squash
    Squash="No_root_squash";
    # NFSv4 Pseudo path
    Pseudo="/kubegfs";
    # allowed security options
    SecType="sys";
}
LOG {
    # default log level DEBUG WARN
    Default_Log_Level = DEBUG;
}
EOF

sudo systemctl restart nfs-ganesha
sudo systemctl enable nfs-ganesha
sudo systemctl status nfs-ganesha
~~~

## Verification

~~~bash
vagrant@node0:~$ mountstats
# No NFS mount points were found
vagrant@node0:~$ showmount -e localhost
# clnt_create: RPC: Program not registered
sudo systemctl stop nfs-ganesha.service && sudo systemctl start nfs-ganesha.service && sleep 5s && tail -n 40 /var/log/ganesha/ganesha.log && sudo systemctl status nfs-ganesha.service
sudo systemctl status nfs-ganesha.service
sudo vi /etc/ganesha/ganesha.conf
grep -v '^\s*$\|^\s*\#' /etc/ganesha/ganesha.conf
rm -rf ~/toto && mkdir ~/toto && sudo apport-unpack  /var/crash/_usr_bin_ganesha.nfsd.0.crash ~/toto
gdb /usr/bin/ganesha.nfsd ~/toto/CoreDump
backtrace
q

~~~
