# Task 69
> The Nautilus DevOps team has recently setup a Jenkins server, which they want to use for some CI/CD jobs. Before that they want to install some plugins which will be used in most of the jobs. Please find below more details about the task
>
> 1. Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and Adm!n321 password.
>
> 2. Once logged in, install the Git and GitLab plugins. Note that you may need to restart Jenkins service to complete the plugins installation, If required, opt to Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre.
>
> Note:
>
> 1. After restarting the Jenkins service, wait for the Jenkins login page to reappear before proceeding.
>
> 2. For tasks involving web UI changes, capture screenshots to share for review or consider using screen recording software like loom.com for documentation and sharing.
>
>

### Install Git & GitLab Plugins on Jenkins

1. Login to Jenkins UI
Òpen your browser and to to
```
http://<your_jenkins_server_ip>:8080/
```

Install Git & GitLab Plugins on Jenkins

Login with:

* Username: admin

* Password: Adm!n321


2. Navigate to Plugin Manager

Inside Jenkins:

Click Manage Jenkins → from the left sidebar

Click Manage Plugins

This opens the Plugin Manager (Update Center)

3. Install the required plugins
Go to the Available tab (or Available Plugins on new UI)

Search for:

🔹 Git
🔹 GitLab

You will find:
Git Plugin (provides Git SCM support)

GitLab Plugin (integrates GitLab with Jenkins)

Steps:

Tick Git Plugin

Tick GitLab Plugin

Click Install without Restart OR Install & Restart

4. Wait for Jenkins to come back up

After restart, WAIT until you see the login page fully loaded again.

Then log in again with the given credentials

5. Confirm the plugins installed

Go to:

Manage Jenkins → Manage Plugins → Installed

Search for:

Git Plugin

GitLab Plugin
