# Task 78
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
> Create a Jenkins pipeline job named devops-webapp-job (it must not be a Multibranch pipeline) and configure it to:
>
> Add a string parameter named BRANCH.
>
> It should conditionally deploy the code from web_app repository under /var/www/html on Storage Server, as this location is already mounted to the document root /var/www/html of app servers. The pipeline should have a single stage named Deploy ( which is case sensitive ) to accomplish the deployment.

> The pipeline should be conditional, if the value master is passed to the BRANCH parameter then it must deploy the master branch, on the other hand if the value feature is passed to the BRANCH parameter then it must deploy the feature branch.
>
>LB server is already configured. You should be able to see the latest changes you made by clicking on the App button. Please make sure the required content is loading on the main URL https://<LBR-URL> i.e there should not be a sub-directory like https://<LBR-URL>/web_app etc.
>
> Note:
>
> You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case, please make sure to refresh the UI page.
>
> For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
>
>

### Jenkins Pipeline + parameterized conditional deployment

1. Add Storage Server as Jenkins Agent (if not already)
You already did this before, but verify:

Manage Jenkins → Nodes → New Node

* Node name: Storage Server

* Type: Permanent Agent

* Remote root directory: /var/www/html

* Labels: ststor01

* Launch method: Launch agent via SSH

* Host: Storage Server IP

* Credentials: SSH private key

* Host Key Verification: Non verifying Verification Strategy

Ensure node shows ONLINE

2. Create the Pipeline Job
Dashboard → New Item

Name: devops-webapp-job

Type: Pipeline (❗ NOT multibranch)

Click OK


3. Add Build Parameter
In job configuration:

Check This project is parameterized

Add String Parameter

Name: BRANCH

Default Value: master

Description: Branch to deploy(master or feature) 


4. Pipeline Configuration
Scroll to Pipeline section:

Definition: Pipeline script

Paste exactly this:
```
pipeline {
    agent { label 'ststor01' }

    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Branch to deploy')
    }

    stages {
        stage('Deploy') {
            steps {
                script {
                    if (params.BRANCH == 'master') {
                        sh '''
                            cd /var/www/html
                            git checkout master
                            git pull origin master
                        '''
                    } else if (params.BRANCH == 'feature') {
                        sh '''
                            cd /var/www/html
                            git checkout feature
                            git pull origin feature
                        '''
                    } else {
                        error "Invalid branch specified. Use master or feature."
                    }
                }
            }
        }
    }
}
```

5. Save & Build
Click Build with Parameters

Test both cases:
Case 1
BRANCH = master

Build → should succeed

6. Verification (Final Check)
Click the App button / LB URL:

```
https://<LBR-URL>
```
