# Task 71
> Some new requirements have come up to install and configure some packages on the Nautilus infrastructure under Stratos Datacenter. The Nautilus DevOps team installed and configured a new Jenkins server so they wanted to create a Jenkins job to automate this task. Find below more details and complete the task accordingly:
>
> 1. Access the Jenkins UI by clicking on the Jenkins button in the top bar. Log in using the credentials: username admin and password Adm!n321.
>
> 2. Create a new Jenkins job named install-packages and configure it with the following specifications:
>
>
> Add a string parameter named PACKAGE.
Configure the job to install a package specified in the $PACKAGE parameter on the storage server within the Stratos Datacenter.
>
> Note:
>
> 1. Ensure to install any required plugins and restart the Jenkins service if necessary. Opt for Restart Jenkins when installation is complete and no jobs are running on the plugin installation/update page. Refresh the UI page if needed after restarting the service.
>
> 2. Verify that the Jenkins job runs successfully on repeated executions to ensure reliability.
>
>

### Jenkins Job to Install Packages on Storage Server

1. Login to Jenkins
Open:
```
http://<jenkins_server_ip>:8080/

```

Login:

Username: admin

Password: Adm!n321

2. Create a New Job (install-packages)
From Jenkins dashboard, click New Item

Enter name:
install-packages

Select:
Freestyle project

Click OK

3. Add the Required Parameter (PACKAGE)
Inside the job configuration:

Scroll to This project is parameterized

Tick ✔ it

Click Add Parameter

Select: String Parameter

Fill:

| Field | Value |
|---|---|
| Name | `PACKAGE` | 
| Default | (optional, e.g., vim) |
| Description | Package to install on storage server |

4. Configure Remote Package Installation
The job must install the package on the storage server (this is typically ststor01 in KodeKloud labs).

You will use an Execute Shell build step:
Scroll to Build → click Add build step → choose:

Execute shell
Inside the shell script, add this:

sshpass -p '<storage_server_password>' ssh -o StrictHostKeyChecking=no storage_server_user@storage_server_ip "sudo dnf install -y $PACKAGE"


In a typical KodeKloud/Nautilus lab:

Storage server user = banner

Password = bl@ckW1d0w

Hostname = ststor01

Or IP = provided in the problem (common: 172.16.238.x)

So full example:
```
sshpass -p 'bl@ckW1d0w' ssh -o StrictHostKeyChecking=no banner@ststor01 "sudo dnf install -y $PACKAGE"
```

If sudo requires password:
```
sshpass -p 'bl@ckW1d0w' ssh -tt -o StrictHostKeyChecking=no banner@ststor01 "echo 'bl@ckW1d0w' | sudo -S dnf install -y $PACKAGE"
```

If sshpass is missing:
Install it on the Jenkins host:
```
dnf install -y sshpass

```

5. Save and Run the Job
Click Save

Click Build with Parameters

Under PACKAGE, enter a test package:

Example:
Example:

htop


Click Build

6. Verify the Job Works

Check console output:

It should show:

Installing: htop
Complete!


Now run again with a different package:

tree


If installation succeeds multiple times, you're DONE.


7. Plugins You May Need

If Jenkins gives SSH-related options:

Install:

SSH Agent Plugin

SSH Credentials Plugin

If the job requires credentials management, add them under:

Manage Jenkins → Credentials → System → Global credentials
