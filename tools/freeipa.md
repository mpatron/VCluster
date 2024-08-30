#!/bin/bash

export IPA_SERVER_PASSWORD=Welcome1!
export IPA_SERVER_NAME=iam
export IPA_SERVER_DOMAIN=jobjects.org
export IPA_SERVER_IP=192.168.122.100

sudo hostnamectl set-hostname $IPA_SERVER_NAME.$IPA_SERVER_DOMAIN

sudo yum -y update
sudo yum -y install ipa-server ipa-server-dns bind bind-dyndb-ldap vim lsof lynx nmap firewalld bind-utils

sudo ipa-server-install --admin-password=$IPA_SERVER_PASSWORD --ds-password=$IPA_SERVER_PASSWORD  --hostname=$IPA_SERVER_NAME.$IPA_SERVER_DOMAIN --ip-address=$IPA_SERVER_IP --domain=$IPA_SERVER_DOMAIN --realm=${IPA_SERVER_DOMAIN^^} --mkhomedir --setup-dns --forwarder=8.8.8.8 --forwarder=8.8.4.4 --auto-reverse --ssh-trust-dns --unattended

printf "$IPA_SERVER_PASSWORD\n" | kinit admin
klist
ipa config-mod --defaultshell=/bin/bash
ipa user-find admin
dig @$IPA_SERVER_NAME.$IPA_SERVER_DOMAIN +short $IPA_SERVER_NAME.$IPA_SERVER_DOMAIN A


sudo firewall-cmd --permanent --add-service={ntp,http,https,ldap,ldaps,kerberos,kpasswd,dns}
sudo firewall-cmd --complete-reload

ipa user-add alice --first="Alice" --last="Savoie"  --email="alice@jobjects.org" --random > ~/user-alice.txt && cat ~/user-alice.txt
ipa user-add bob --first="Bob" --last="Marley"  --email="bob@jobjects.org" --random > ~/user-bob.txt && cat ~/user-bob.txt
ipa user-add carole --first="Carole" --last="Rousseau"  --email="carole@jobjects.org" --random > ~/user-carole.txt && cat ~/user-carole.txt
ipa user-add dave --first="Dave" --last="Levenbach"  --email="dave@jobjects.org" --random > ~/user-dave.txt && cat ~/user-dave.txt
ipa user-add eve --first="Eve" --last="Angeli"  --email="eve@jobjects.org" --random > ~/user-eve.txt && cat ~/user-eve.txt
ipa user-add franck --first="Frank" --last="Dubosc"  --email="franck@jobjects.org" --random > ~/user-franck.txt && cat ~/user-franck.txt

[root@freeipa ~]# cat /etc/resolv.conf
# Generated by NetworkManager
search jobjects.org
nameserver 192.168.56.110
nameserver 192.168.0.254

ipa dnsrecord-add 56.168.192.in-addr.arpa. 111 --ptr-rec=gitlab.jobjects.org.
ipa dnsrecord-add 56.168.192.in-addr.arpa. 112 --ptr-rec=mail.jobjects.org.
ipa dnsrecord-add 56.168.192.in-addr.arpa. 113 --ptr-rec=gui.jobjects.org.
ipa dnsrecord-add 56.168.192.in-addr.arpa. 114 --ptr-rec=keycloak.jobjects.org.
ipa dnsrecord-add 56.168.192.in-addr.arpa. 115 --ptr-rec=wildfly.jobjects.org.
ipa dnsrecord-add 56.168.192.in-addr.arpa. 116 --ptr-rec=docker.jobjects.org.

Lien du ca.crt de Freeipa :
http://freeipa.jobjects.org/ipa/config/ca.crt

http://directory.apache.org/studio/downloads.html
ldaps://iam.jobjects.org:636
user     : uid=admin,cn=users,cn=accounts,dc=jobjects,dc=org
password : $IPA_SERVER_PASSWORD
DN: cn=admins,cn=groups,cn=accounts,dc=jobjects,dc=org


ipa service-add monservice/mamachine.jobjects.org
ipa-getcert request -r -f /etc/ssl/certs/monservice.crt -k /etc/ssl/certs/monservice.key -K monservice/mamachine.jobjects.org

sudo ipa-getcert list

## FreeIPA Client
export IPA_SERVER_PASSWORD=Welcome1!
export IPA_SERVER_NAME=iam
export IPA_SERVER_DOMAIN=jobjects.org
export IPA_SERVER_IP=192.168.122.100
sudo hostnamectl set-hostname vault.jobjects.org
sudo apt update && sudo apt install -yqq freeipa-client
sudo ipa-client-install --server=$IPA_SERVER_NAME.$IPA_SERVER_DOMAIN --domain=$IPA_SERVER_DOMAIN --ntp-server=0.fr.pool.ntp.org -U -p admin -w $IPA_SERVER_PASSWORD
ipa dnsrecord-add jobjects.org vault --a-rec 192.168.122.101
ipa dnsrecord-add 122.168.192.in-addr.arpa. 101 --ptr-rec=vault.jobjects.org.
sudo authconfig --enablemkhomedir --update
printf "$IPA_SERVER_PASSWORD\n" | kinit admin
klist
dig +short vault.jobjects.org @iam.jobjects.org

sudo bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
required pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
sudo pam-auth-update


## Hashicopr Vault
https://medium.com/@mitesh_shamra/setup-hashicorp-vault-using-ansible-fa8073a70a56
https://github.com/MiteshSharma/AnsibleVaultRole


sudo apt update && sudo apt install gpg
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
798A EC65 4E5C 1542 8C8E 42EE AA16 FCBC A621 E701,
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

sudo mv /etc/netplan/01-netplan.old /etc/netplan/01-netplan.yaml && sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.old
sudo netplan apply && sudo systemctl restart systemd-networkd
mpatron@vault:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:9e:96:f7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.101/24 brd 192.168.122.255 scope global enp1s0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe9e:96f7/64 scope link 
       valid_lft forever preferred_lft forever
mpatron@vault:~$ ip route
default via 192.168.122.1 dev enp1s0 proto static 
192.168.122.0/24 dev enp1s0 proto kernel scope link src 192.168.122.101 
mpatron@vault:~$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
mpatron@vault:~$ cat /etc/netplan/01-netplan.yaml 
network:
  renderer: networkd
  version: 2
  ethernets:
    enp1s0:
      addresses: [192.168.122.101/24]
      # gateway4: 192.168.1.1
      routes:
        - to: default
          via: 192.168.122.1
      nameservers:
        addresses: [192.168.122.100,192.168.1.1]
      dhcp4: false
      dhcp6: false


ssh-keygen -t rsa -b 4096 -C "$USER@$HOSTNAME"
ssh-copy-id -f "$USER@$HOSTNAME"

git clone https://github.com/MiteshSharma/AnsibleVaultRole
sudo mkdir -R /home/vault/data
sudo chown vault:vault /home/vault/data
mpatron@vault:~/AnsibleVaultRole$ git diff
diff --git a/ansible.cfg b/ansible.cfg
index 89c6ae5..b97ce6e 100644
--- a/ansible.cfg
+++ b/ansible.cfg
@@ -1,3 +1,3 @@
 [defaults]
 inventory = ./inventory
-remote_user = ec2-user
\ No newline at end of file
+remote_user = mpatron
diff --git a/inventory b/inventory
index 827070a..5d5e2c8 100644
--- a/inventory
+++ b/inventory
@@ -1,2 +1,2 @@
 [all]
-18.219.26.226
\ No newline at end of file
+192.168.122.101
diff --git a/roles/vault/templates/vault.hcl.j2 b/roles/vault/templates/vault.hcl.j2
index 94bf270..481c4fa 100644
--- a/roles/vault/templates/vault.hcl.j2
+++ b/roles/vault/templates/vault.hcl.j2
@@ -1,11 +1,8 @@
-storage "s3" {
-  access_key = "ACCESS_KEY_HERE"
-  secret_key = "SECRET_KEY_HERE"
-  bucket     = "vault-secret"
-  region        = "us-east-2"
+storage "file" {
+  path = "/home/vault/data"
 }
 
 listener "tcp" {
        address     = "0.0.0.0:8200"
        tls_disable = 1
-}
\ No newline at end of file
+}
https://developer.hashicorp.com/vault/docs/configuration/storage/filesystem