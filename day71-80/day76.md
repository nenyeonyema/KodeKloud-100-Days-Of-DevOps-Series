# Task 76
>
> The xFusionCorp Industries has recruited some new developers. There are already some existing jobs on Jenkins and two of these new developers need permissions to access those jobs. The development team has already shared those requirements with the DevOps team, so as per details mentioned below grant required permissions to the developers.
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321.
>
> There is an existing Jenkins job named Packages, there are also two existing Jenkins users named sam with password sam@pass12345 and rohan with password rohan@pass12345.
>
>
> Grant permissions to these users to access Packages job as per details mentioned below:
>
> * Make sure to select Inherit permissions from parent ACL under inheritance strategy for granting permissions to these users.
>
> * Grant mentioned permissions to sam user : build, configure and read.
>
> * Grant mentioned permissions to rohan user : build, cancel, configure, read, update and tag.
>
> Note:
>
> Please do not modify/alter any other existing job configuration.
>
> You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case, please make sure to refresh the UI page.
>
> For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>

### Grant Job-Level Permissions in Jenkins

1. Login to Jenkins

Open Jenkins UI

* Username: admin

* Password: 

2. Open the Job Configuration
* From Dashboard, click the job Packages

* Click Configure

Do not change anything else in the job.


3. Enable Job-Level Authorization
Scroll to Authorization section.

* Check Enable project-based security

* Under Inheritance Strategy, select:
* Inherit permissions from parent ACL

4. Add User: sam
Click Add user or group

Enter: `sam`

Grant ONLY these permissions:

* Job → Read

* Job → Build

* Job → Configure

5. Add User: rohan
Click Add user or group

Enter: `rohan`
Grant ONLY these permissions:

* Job → Read

* Job → Build

* Job → Cancel

* Job → Configure

* Job → Update

* Job → Tag

5. Save Configuration
Click Save

6. Verify Permissions
Log out → log in as each user.
