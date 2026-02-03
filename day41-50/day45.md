# Task 45
> The Nautilus DevOps team is working to create new images per requirements shared by the development team. One of the team members is working to create a Dockerfile on App Server 2 in Stratos DC. 
> While working on it she ran into issues in which the docker build is failing and displaying errors. Look into the issue and fix it to build an image as per details mentioned below:
>
>
> * The Dockerfile is placed on App Server 2 under /opt/docker directory.
>
> * Fix the issues with this file and make sure it is able to build the image.
>
> * Do not change base image, any other valid configuration within Dockerfile, or any of the data been used — for example, index.html.


### Debugging a Bad Dockerfile on App Server 2 

1. SSH into App server 2
```
ssh steve@stapp02

```

2. Navigate to the Dockerfile
```
cd /opt/docker
ls -l
cat Dockerfile
```

3. Debug the Dockerfile
```
vi /opt/docker/Dockerfile
```

**Content of the Bugged Dockerfile**

```
IMAGE httpd:2.4.43

ADD sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf

ADD sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' conf/httpd.conf

ADD sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' conf/httpd.conf

ADD sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' conf/httpd.conf

COPY certs/server.crt /usr/local/apache2/conf/server.crt

COPY certs/server.key /usr/local/apache2/conf/server.key

COPY html/index.html /usr/local/apache2/htdocs/                                
```
**Errros identified**

* `IMAGE` should be changed to `FROM`
* `ADD` is not used to execute commands and should be changed to `RUN`
* Wrong path to the configuration file and should be changed to:
```
/usr/local/apache2/conf/httpd.conf
/usr/local/apache2/conf/extra/httpd-ssl.conf

```
**The Correct Debugged Dockerfile**

```
FROM httpd:2.4.43

RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule ssl_module modules\/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf
RUN sed -i '/LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' /usr/local/apache2/conf/httpd.conf

RUN sed -i '/Include conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf

COPY certs/server.crt /usr/local/apache2/conf/server.crt
COPY certs/server.key /usr/local/apache2/conf/server.key

COPY html/index.html /usr/local/apache2/htdocs/

```
*Save and exit*

4. Test the fixed Dockerfile by building an image
```
docker build -t fixed-httpd .
```

5. Run the container
```
docker run -d --name httpd-test -p 8080:8080 fixed-httpd

```
*Confirm is runnig*
```
docker ps
```

6. Test with curl
```
curl http://localhost:8080
```
