# Task 77
>
> The development team of xFusionCorp Industries is working on to develop a new static website and they are planning to deploy the same on Nautilus App Servers using Jenkins pipeline. They have shared their requirements with the DevOps team and accordingly we need to create a Jenkins pipeline job. Please find below more details about the task:
>
> Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321.
>
> Similarly, click on the Gitea button on the top bar to access the Gitea UI. Login using username sarah and password Sarah_pass123. There under user sarah you will find a repository named web_app that is already cloned on Storage server under /var/www/html. sarah is a developer who is working on this repository.
>
> Add a slave node named Storage Server. It should be labeled as ststor01 and its remote root directory should be /var/www/html.
>
> We have already cloned repository on Storage Server under /var/www/html.
>
> Apache is already installed on all app Servers its running on port 8080.
>
> Create a Jenkins pipeline job named datacenter-webapp-job (it must not be a Multibranch pipeline) and configure it to:
>
> Deploy the code from web_app repository under /var/www/html on Storage Server, as this location is already mounted to the document root /var/www/html of app servers. The pipeline should have a single stage named Deploy ( which is case sensitive ) to accomplish the deployment.
>
> LB server is already configured. You should be able to see the latest changes you made by clicking on the App button. Please make sure the required content is loading on the main URL https://<LBR-URL> i.e there should not be a sub-directory like https://<LBR-URL>/web_app etc.
>
> Note:
>
> You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case, please make sure to refresh the UI page.
>
> For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
> 


### Jenkins Pipeline Deployment


1. Login
Jenkins UI → login
admin / Adm!n321

Gitea UI → login
sarah / Sarah_pass123

2. Add Storage Server as Jenkins Agent
Go to:
Manage Jenkins → Nodes → New Node

Configure node:
Node name: Storage Server

Type: Permanent Agent

Click Create
Node configuration:
Remote root directory: /var/www/html

Labels: ststor01

Usage: Use this node as much as possible

Launch method: SSH

Credentials:
Use the same SSH credentials you already fixed earlier (key-based)

Host Key Verification Strategy:
Non-verifying Verification Strategy

Click Save
Ensure node becomes ONLINE

3. Create the Pipeline Job
Go to:
Jenkins Dashboard → New Item

Name: datacenter-webapp-job

Type: Pipeline
Do NOT select Multibranch

Click OK

4. Configure the Pipeline
Scroll to Pipeline section:

Definition: Pipeline script

Paste this exact script

```
pipeline {
    agent { label 'ststor01' }

    stages {
        stage('Deploy') {
            steps {
                sh '''
                cd /var/www/html
                if [ ! -d web_app ]; then
                    git clone http://gitea.stratos.xfusioncorp.com/sarah/web_app.git
                else
                    cd web_app
                    git pull
                fi
                '''
            }
        }
    }
}
```

Stage name Deploy is case-sensitive

Code is deployed directly under /var/www/html

No subdirectory exposure (LB serves /var/www/html directly)

5. Save & Build
Click Save

Click Build Now

Build should finish SUCCESS


6. Verify Deployment
Click App button (Load Balancer URL)

OR open:
```
https://<LBR-URL>
```
