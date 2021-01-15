# ansible
contains Ansible ad-hoc commands and playbooks
## ad-hoc Ansible commands
```
ansible localhost -m ping
ansible localhost -m stat -a "path=/ansible"
ansible localhost -m copy -a "src=/ansible/info.md dest=/ansible/to-dos.md"
ansible localhost -m replace -a "path=/ansible/to-dos.md regexp='^\[\s' replace='[x'"
ansible localhost -m debug -a "msg={{lookup('file', '/ansible/to-dos.md') }}"
ansible localhost -m file -a "path=/ansible/to-dos.md state=absent"
ansible all -i <Public Ip Address>, -m ping -e "ansible_user=ansible ansible_password=<Password> ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
ansible all -i <Public IP Address>, -m win_ping -e "ansible_user=ansible ansible_password=<Password> ansible_winrm_server_cert_validation=ignore ansible_connection=winrm"
```
