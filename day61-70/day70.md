# Task 70
> The Nautilus team is integrating Jenkins into their CI/CD pipelines. After setting up a new Jenkins server, they're now configuring user access for the development team, Follow these steps:
>
> 1. Click on the Jenkins button on the top bar to access the Jenkins UI. Login with username admin and password Adm!n321.
>
> 2. Create a jenkins user named siva with the passwordRc5C9EyvbU. Their full name should match Siva.
>
> 3. Utilize the Project-based Matrix Authorization Strategy to assign overall read permission to the siva user.
>
> 4. Remove all permissions for Anonymous users (if any) ensuring that the admin user retains overall Administer permissions.
>
> 5. For the existing job, grant siva user only read permissions, disregarding other permissions such as Agent, SCM etc.
>
>
> Note:
>
> 1. You may need to install plugins and restart Jenkins service. After plugins installation, select Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page.
>
>
> 2. After restarting the Jenkins service, wait for the Jenkins login page to reappear before proceeding. Avoid clicking Finish immediately after restarting the service.
>
> 3. Capture screenshots of your configuration for review purposes. Consider using screen recording software like loom.com for documentation and sharing.
>
>


### Jenkins User & Authorization Setup
1. Login to Jenkins

Open your browser:

```
http://<jenkins_server_ip>:8080/
```

Login with:

Username: admin

Password: Adm!n321


2. Create a New User (siva)

Inside Jenkins:

Click Manage Jenkins (left sidebar)

Click Manage Users

Click Create User

Fill in the credentials of Siva.


3. Enable Project-based Matrix Authorization Strategy

Still in Manage Jenkins:

Click Configure Global Security

Under Authorization, select:

Project-based Matrix Authorization Strategy

4. Configure Permissions
You will now see a big permissions table.
A. Give admin full access

Find the admin row.

Tick:

✔ Overall → Administer

(This auto-ticks everything. Leave it.)

B. Add the user siva and give only minimal permissions

Scroll to the bottom of the table

Click Add user or group

Enter: siva

Click OK

Now in the siva row:

✔ Tick ONLY:

Overall → Read

All other boxes remain unchecked.

5. Remove all permissions from Anonymous users

Find the Anonymous row.

Uncheck every single box.

Anonymous should have 0 permissions.

6. Apply and Save

Scroll down and click:

👉 Save

7. Assign Job-Level Permissions for siva

The task says:

For the existing job, grant siva user only read permissions.

Do this:

Go to Dashboard

Click the job (e.g., my-job or whatever job is already there)

Click Configure

Scroll down to Build Authorization or Project-based Matrix Authorization
(If not visible, job must have “Enable project-based security” checked)

Tick:

✔ Enable Project-based Matrix Authorization

Inside the job permissions table:

For user siva, tick ONLY:

Job → Read

That’s it.

Click Save

📌 REQUIRED PLUGIN (Install if missing)

If "Project-based Matrix Authorization Strategy" doesn’t appear:

Install:

Matrix Authorization Strategy Plugin

Steps:

Manage Jenkins → Manage Plugins

Available tab → Search matrix authorization

Install

Choose: Restart Jenkins when installation is complete and no jobs are running

Wait for Jenkins to fully reboot.
