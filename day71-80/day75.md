# Task 75
>
> The Nautilus DevOps team has installed and configured new Jenkins server in Stratos DC which they will use for CI/CD and for some automation tasks. There is a requirement to add all app servers as slave nodes in Jenkins so that they can perform tasks on these servers using Jenkins. Find below more details and accomplish the task accordingly.
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321.
>
> 1. Add all app servers as SSH build agent/slave nodes in Jenkins. Slave node name for app server 1, app server 2 and app server 3 must be App_server_1, App_server_2, App_server_3 respectively.
>
> 2. Add labels as below:
>
> App_server_1 : stapp01
>
> App_server_2 : stapp02
>
> App_server_3 : stapp03
>
> 3. Remote root directory for App_server_1 must be /home/tony/jenkins, for App_server_2 must be /home/steve/jenkins and for App_server_3 must be /home/banner/jenkins.
>
> 4. Make sure slave nodes are online and working properly.
>
> Note:
>
> 1. You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case, please make sure to refresh the UI page.
>
> 2. For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>

### Add All App Servers as Jenkins SSH Build Agents (Slave Nodes)

1. Login to Jenkins
Click the Jenkins button → login:

User: 

Password:

2. Server Details (Needed for Configuration)

3. Install Required Jenkins Plugin
Before creating agents:

Go to:
Manage Jenkins → Manage Plugins → Available

Search for:

**SSH Build Agents Plugin**
(or SSH Slaves on some versions)

Install it →
Then select:

*Restart Jenkins when installation is complete and no jobs are running*

Refresh page if UI freezes.

4. Create Each SSH Agent (Slave Node)
Repeat for App server 1, 2, 3

**Add App Server 1**
*Go to Manage Jenkins → Manage Nodes & Clouds*

* Click New Node

* Enter: App_server_1

* Choose: Permanent Agent

Configure:

Node Configuration

```
Name	App_server_1
Number of executors 1
Remote root directory	/home/tony/jenkins
Labels	stapp01
Launch method	Launch agents via SSH
Host Ip Address
```

Add Credentials
Click Credentials → Add:

Kind: Username + Password

Username: tony

Password: 

ID: tony-ssh

Click Add → Select it

Click Save

B. Add App Server 2
Name: App_server_2

Label: stapp02

Host: Ip Address

Remote root: /home/steve/jenkins

Username: steve

Password: 

C. Add App Server 3
Repeat with:

Name: App_server_3

Label: stapp03

Host: Ip Address

Remote root: /home/banner/jenkins

Username: banner

Password:


5. Verify Agents Are ONLINE
After saving each node:

* Jenkins will connect via SSH
* Create remote directory
* Start agent .jar
* Node should show green "online" status

