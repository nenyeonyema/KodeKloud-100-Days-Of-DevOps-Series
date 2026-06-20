# Task 83

> An Ansible playbook needs completion on the jump host, where a team member left off. Below are the details:
>
> The inventory file /home/thor/ansible/inventory requires adjustments. The playbook must run on App Server 3 in Stratos DC. Update the inventory accordingly.
>
> Create a playbook /home/thor/ansible/playbook.yml. Include a task to create an empty file /tmp/file.txt on App Server 3.
>
> Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook works without any additional arguments.
>
>

## 

1. Go to ansible directory on jump host
```
cd /home/thor/ansible
```

2. Edit inventory file
```
vi inventory
```

**Paste** 
```
[appservers]
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=banner ansible_python_interpreter=/usr/bin/python3
```

3. Create playbook file
```
vi playbook.yml
```

**Paste**
```
---
- name: Create empty file on App Server 3
  hosts: appservers
  become: yes
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
```

4. Test inventory connectivity
```
ansible -i inventory appservers -m ping
```

5. Run playbook exactly as validator will
```
ansible-playbook -i inventory playbook.yml
```

6. Verify on App Server 3
```
ssh banner@stapp03
ls -l /tmp/file.txt
```
