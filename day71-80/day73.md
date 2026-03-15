# Task 73
> The devops team of xFusionCorp Industries is working on to setup centralised logging management system to maintain and analyse server logs easily. Since it will take some time to implement, they wanted to gather some server logs on a regular basis. At least one of the app servers is having issues with the Apache server. The team needs Apache logs so that they can identify and troubleshoot the issues easily if they arise. So they decided to create a Jenkins job to collect logs from the server. Please create/configure a Jenkins job as per details mentioned below:
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321
>
> 1. Create a Jenkins jobs named copy-logs.
>
> 2. Configure it to periodically build every 2 minutes to copy the Apache logs (both access_log and error_logs) from App Server 3 (from default logs location) to location /usr/src/security on Storage Server.
>
> Note:
>
> 1. You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case please make sure to refresh the UI page.
>
> 2. Please make sure to define you cron expression like this */10 * * * * (this is just an example to run job every 10 minutes).
>
> 3. For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>
>
### Jenkins Scheduled Jobs to Copy Apache Logs Every 2 Minutes

1. Login to Jenkins
Click the Jenkins button on the top bar

Login:

Username: 

Password: 


2. Create the Job
Click New Item

Enter name: copy-logs

Select Freestyle project

Click OK


3. Configure Periodic Build (Every 2 Minutes)

Scroll to Build Triggers:

* Check Build periodically

* Enter this cron expression:
```text
*/2 * * * *
```
This triggers the job every 2 minutes.


4. Add the Shell Script to Copy Logs
Assuming App Server 3 login credentials (as used in all Nautilus tasks):

User: banner

Password: 

App Server 3 IP: 

Storage Server user: natasha

Password: 

Destination: /usr/src/security
SSH/SCP command structure
Go to:

Build → Add build step → Execute shell

Paste this script:
```
#!/bin/bash

# App Server 3 details
APP_USER=banner
APP_PASS="GrodNedJ"
APP_IP=172.16.238.12

# Storage Server details
STORAGE_USER=natasha
STORAGE_PASS="Bl@kW"
STORAGE_IP=172.16.238.15
DEST_DIR="/usr/src/security"

# Copy Apache logs from App Server 3 to Storage Server
sshpass -p "$APP_PASS" scp -o StrictHostKeyChecking=no $APP_USER@$APP_IP:/var/log/httpd/access_log /tmp/access_log
sshpass -p "$APP_PASS" scp -o StrictHostKeyChecking=no $APP_USER@$APP_IP:/var/log/httpd/error_log /tmp/error_log

# Move the logs to the security directory
sshpass -p "$STORAGE_PASS" scp -o StrictHostKeyChecking=no /tmp/access_log /tmp/error_log $STORAGE_USER@$STORAGE_IP:$DEST_DIR/
```

5. Save & Validate
Click Save

Click Build Now (optional test run)

After successful test → Wait 2 minutes and verify that logs appear in:

/usr/src/security
on the Storage Server.
