#
source config.sh
ssh-keygen -t rsa -b 2048
ssh-copy-id $vm_connection