# Task 80
>
> The DevOps team was looking for a solution where they want to restart Apache service on all app servers if the deployment goes fine on these servers in Stratos Datacenter. After having a discussion, they came up with a solution to use Jenkins chained builds so that they can use a downstream job for services which should only be triggered by the deployment job. So as per the requirements mentioned below configure the required Jenkins jobs.
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and Adm!n321 password.
>
> Similarly you can access Gitea UI on port 8090 and username and password for Git is sarah and Sarah_pass123 respectively. Under user sarah you will find a repository named web.
>
> Apache is already installed and configured on all app server so no changes are needed there. The doc root /var/www/html on all these app servers is shared among the Storage server under /var/www/html directory.
>
> 1. Create a Jenkins job named nautilus-app-deployment and configure it to pull change from the master branch of web repository on Storage server under /var/www/html directory, which is already a local git repository tracking the origin web repository. Since /var/www/html on Storage server is a shared volume so changes should auto reflect on all apps.
>
> 2. Create another Jenkins job named manage-services and make it a downstream job for nautilus-app-deployment job. Things to take care about this job are:
> 
> a. This job should restart httpd service on all app servers.
>
> b. Trigger this job only if the upstream job i.e nautilus-app-deployment is stable.
>
> LB server is already configured. Click on the App button on the top bar to access the app. You should be able to see the latest changes you made. Please make sure the required content is loading on the main URL https://<LBR-URL> i.e there should not be a sub-directory like https://<LBR-URL>/web etc.
>
> Note:
>
> 1. You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also some times Jenkins UI gets stuck when Jenkins service restarts in the back end so in such case please make sure to refresh the UI page.
>
> 2. Make sure Jenkins job passes even on repetitive runs as validation may try to build the job multiple times.
>
> 3. Deployment related tasks should be done by sudo user on the destination server to avoid any permission issues so make sure to configure your Jenkins job accordingly.
>
> 4. For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>

### Jenkins Chained Builds


1. Fix permissions once (on Storage Server)

Login to Storage Server:

```
sudo chown -R jenkins:jenkins /var/www/html
sudo chmod -R 775 /var/www/html
```
This fixes all the permission denied errors forever.


2. Ensure `/var/www/html` is a git repo

On Storage Server:
```
cd /var/www/html
git init
git remote add origin http://git.stratos.xfusioncorp.com/sarah/web.git
git pull origin master
```
Now this folder is the live deployment directory.

3. Jenkins Job 1
nautilus-app-deployment

Type: Freestyle Project

Source Code Management

Select None
(do NOT use Jenkins git plugin here)

Build Step → Execute Shell
```
cd /var/www/html
git reset --hard
git clean -fd
git pull origin master
```
That is all.
No sudo. No scp. No sshpass.

4. Jenkins Job 2
manage-services

Type: Freestyle Project

Build Triggers

Build after other projects are built

Projects to watch: nautilus-app-deployment
Trigger only if build is stable
Build Step → Execute Shell

```
for server in stapp01 stapp02 stapp03
do
  ssh -o StrictHostKeyChecking=no $server "sudo systemctl restart httpd"
done
```
Jenkins user must already have passwordless sudo on app servers.


5. Configure passwordless sudo (once on all App Servers)

Login to each App Server:
```
sudo visudo
```
Add at bottom:

```
jenkins ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd
```


6. Final Test

Login to Gitea:
```
su sarah
cd /home/sarah/web
nano index.html
git add .
git commit -m "Updated welcome message"
git push origin master
```
