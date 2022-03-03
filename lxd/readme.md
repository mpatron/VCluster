https://lxdware.com/persistent-storage-on-lxd-instances/
lxc list --format json | jq -r '.[] | .state.network.eth0.addresses | .[] | select (.family == "inet") | (.address)'
https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e
lxc image list images: | grep -i ubuntu | grep x86_64 | grep focal



# Pour Avoir community.general.lxd
ansible-galaxy collection install community.general

# Véeification
ansible-inventory --graph --vars
ansible all -m raw -a "sudo hwclock --hctosys && date"
ansible-playbook -i inventory -vvvv playbook.yml
