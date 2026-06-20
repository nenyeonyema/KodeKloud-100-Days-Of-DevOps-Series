# Task 82
>
> The Nautilus DevOps team is testing Ansible playbooks on various servers within their stack. They've placed some playbooks under /home/thor/playbook/ directory on the jump host and now intend to test them on app server 1 in Stratos DC. However, an inventory file needs creation for Ansible to connect to the respective app. Here are the requirements:
>
> a. Create an ini type Ansible inventory file /home/thor/playbook/inventory on jump host.
>
> b. Include App Server 1 in this inventory along with necessary variables for proper functionality.
>
> c. Ensure the inventory hostname corresponds to the server name as per the wiki, for example stapp01 for app server 1 in Stratos DC.
>
> Note: Validation will execute the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.
>
> 

1. Step 1: Go to playbook directory
```
cd /home/thor/playbook
```

2. Create inventory file
```
vi inventory
```
**Paste**
```
[appservers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=tony ansible_python_interpreter=/usr/bin/python3
```

4. Test inventory connectivity
```
ansible -i inventory appservers -m ping
```

5. Run playbook as validator will
```
ansible-playbook -i inventory playbook.yml
```
