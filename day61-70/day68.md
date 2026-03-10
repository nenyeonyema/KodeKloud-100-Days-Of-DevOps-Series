# Task 68
> The DevOps team at xFusionCorp Industries is initiating the setup of CI/CD pipelines and has decided to utilize Jenkins as their server. Execute the task according to the provided requirements:
>
>
> 1. Install Jenkins on the jenkins server using the yum utility only, and start its service.
>
> If you face a timeout issue while starting the Jenkins service, refer to this.
> 2. Jenkin's admin user name should be theadmin, password should be Adm!n321, full name should be Javed and email should be javed@jenkins.stratos.xfusioncorp.com.
>
> Note:
>
> 1. To access the jenkins server, connect from the jump host using the root user with the password S3curePass.
>
> 2. After Jenkins server installation, click the Jenkins button on the top bar to access the Jenkins UI and follow on-screen instructions to create an admin user.
>
>


### Install & Configure Jenkins via YUM + Create Admin User

1. SSH into the Jenkins Server
From the jump host, run:

```
ssh root@jenkins.stratos.xfusioncorp.com
```
*Enter the password as prompted*

2. Remove any wrong Jenkins repo file
* Clean up
```
rm -f /etc/yum.repos.d/jenkins.repo
dnf clean all
rm -rf /var/cache/dnf
```

2. Add the official Jenkins repo
* Uses HTTPS and Correct Keys
```
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

*Verify the key imported*
```
rpm -qa gpg-pubkey*
```

3. Install Java 21 + Fontconfig (required for Jenkins UI)
Run: 
```
dnf install -y fontconfig java-21-openjdk java-21-openjdk-devel
```

*Verify that Java 21 is installed correctly*
```
java -version
```

4. Enable and start Jenkins service
```
systemctl enable jenkins
systemctl restart jenkins
systemctl status jenkins
```
