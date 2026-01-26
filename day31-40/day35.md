---
**Task 35**
The Nautilus DevOps team aims to containerize various applications following a recent meeting with the application development team. They intend to conduct testing with the following steps:


Install docker-ce and docker compose packages on App Server 2.

Initiate the docker service. 

---

### TASK 35: Docker and Docker-Compose Installation

1. SSH into App Server 2
Use the credentials provided for the KodeKloud lab:
```
ssh steve@stapp02
```
Switch to root:
```
sudo -i
```
2. Install Required Dependencies
Docker requires some supporting packages:
```
yum install -y yum-utils device-mapper-persistent-data lvm2
```

3. Add the Official Docker Repository

```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

4. Install Docker CE
```
yum install -y docker-ce docker-ce-cli containerd.io
```
5. Install Docker Compose
```
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```

Confirm installation
```
docker-compose --version
docker --version
```

6. Start and Enable Docker Service
```
systemctl start docker
systemctl enable docker
systemctl status docker
```

You should see active (running)

7. Add Current User to docker Group
If you're not root:
```
usermod -aG docker $USER
```
Then log out and back in.
