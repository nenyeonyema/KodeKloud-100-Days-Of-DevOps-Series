# Task 74
> There is a requirement to create a Jenkins job to automate the database backup. Below you can find more details to accomplish this task:
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321.
>
> Create a Jenkins job named database-backup.
>
> Configure it to take a database dump of the kodekloud_db01 database present on the Database server in Stratos Datacenter, the database user is kodekloud_roy and password is asdfgdsd.
>
> The dump should be named in db_$(date +%F).sql format, where date +%F is the current date.
>
> Copy the db_$(date +%F).sql dump to the Backup Server under location /home/clint/db_backups.
>
> Further, schedule this job to run periodically at */10 * * * * (please use this exact schedule format).
>
> Note:
>
> You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case please make sure to refresh the UI page.
>
> Please make sure to define you cron expression like this */10 * * * * (this is just an example to run job every 10 minutes).
>
> For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>

### Jenkins Job to Automate Database Backup

1. Login to Jenkins
Click the Jenkins button → login:

Username: 

Password:

2. Create the Jenkins Job
Click New Item

Enter: database-backup

Choose Freestyle project

Click OK

3. Schedule Job to Run Every 10 Minutes
Scroll to Build Triggers

* Check Build periodically
* Add this exact cron expression:
```text
 */10 * * * *
```
This runs the job every 10 minutes.

4. Add Shell Script to Perform DB Backup
Below are the required Stratos Datacenter details:

Database Server
User: peter

Password: 

IP:

Database: 

DB user:

DB user: kodekloud_roy

DB pass: 

Backup Server
User: clint

Password: 

IP: 

Destination dir: /home/clint/db_backups


**In Jenkins:**

Go to Build → Add build step → Execute shell

Paste this script:

```
#!/bin/bash

# Vars
DB_SERVER=172.16.238.10
DB_USER=kodekloud_roy
DB_PASS="asdfgdsd"
DB_NAME=kodekloud_db01

DB_SSH_USER=peter
DB_SSH_PASS="KbRpPsdDxG"

BACKUP_SERVER=172.16.238.16
BACKUP_USER=clint
BACKUP_PASS="Ir0nM@n"
DEST_DIR="/home/clint/db_backups"

# Filename
FILE="db_$(date +%F).sql"

# Dump DB on Jenkins workspace
sshpass -p "$DB_SSH_PASS" ssh -o StrictHostKeyChecking=no $DB_SSH_USER@$DB_SERVER \
"mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > /tmp/$FILE"

# Copy dump from DB server to Jenkins
sshpass -p "$DB_SSH_PASS" scp -o StrictHostKeyChecking=no $DB_SSH_USER@$DB_SERVER:/tmp/$FILE .

# Copy dump from Jenkins to Backup Server
sshpass -p "$BACKUP_PASS" scp -o StrictHostKeyChecking=no $FILE $BACKUP_USER@$BACKUP_SERVER:$DEST_DIR/

```

5. Save & Test
Click Save

Click Build Now to test manually

Check Backup Server:
```
ls /home/clint/db_backups
```
