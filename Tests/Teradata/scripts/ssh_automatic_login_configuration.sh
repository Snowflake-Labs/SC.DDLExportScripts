#
source config.sh
ssh-keygen -t rsa -b 2048
ssh-copy-id -p $vm_ssh_port $vm_connection