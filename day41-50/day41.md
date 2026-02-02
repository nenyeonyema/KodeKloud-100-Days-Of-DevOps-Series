# Task 41

> task 41: As per recent requirements shared by the Nautilus application development team, they need custom images created for one of their projects. Several of the initial testing requirements are already been shared with DevOps team.
> Therefore, create a docker file /opt/docker/Dockerfile (please keep D capital of Dockerfile) on App server 3 in Stratos DC and configure to build an image with the following requirements:

> * Use ubuntu:24.04 as the base image.


> * Install apache2 and configure it to work on 3003 port. (do not update any other Apache configuration settings like document root etc).

### Create a Dockerfile at /opt/docker/

1. Go into the working directory
```
cd /opt/docker/
```

2. Create a Dockerfile
```
vi Dockerfile
```
*Paste*

```
FROM ubuntu:24.04

# Install apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean

# Change Apache port from 80 → 3003
RUN sed -i "s/Listen 80/Listen 3003/" /etc/apache2/ports.conf && \
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:3003>/" /etc/apache2/sites-available/000-default.conf

# Expose the custom port
EXPOSE 3003

# Start apache in the foreground (required inside containers)
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

```

3. Build the Docker image - from the Dockerfile
```
docker build -t custom-apache:3003 .

```

4. Run the container using the built image
```
docker run -d -p 3003:3003 --name test-apache custom-apache:3003

```

*Test*

```
curl http://localhost:3003

```
