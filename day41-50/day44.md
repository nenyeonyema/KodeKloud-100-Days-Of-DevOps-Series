# Task 44
> The Nautilus application development team shared static website content that needs to be hosted on the httpd web server using a containerised platform. The team has shared details with the DevOps team, and we need to set up an environment according to those guidelines. Below are the details:
>
> * On App Server 1 in Stratos DC create a container named httpd using a docker compose file /opt/docker/docker-compose.yml (please use the exact name for file).
>
> * Use httpd (preferably latest tag) image for container and make sure container is named as httpd; you can use any name for service.
>
> * Map 80 number port of container with port 8083 of docker host.
>
> * Map container's /usr/local/apache2/htdocs volume with /opt/security volume of docker host which is already there. (please do not modify any data within these locations).


### Deploy httpd using Docker Compose 

1. SSH into App server 1
```
ssh tony@stapp01

```

2. Create the directory if it does not exist
```
sudo mkdir -p /opt/docker

```
3. Create Docker-Compose file `docker-compose.yml`

```
sudo vi /opt/docker/docker-compose.yml

```
*Add the following to the docker-compose.yml file*

```
version: '3.8'

services:
  webserver:
    image: httpd:latest
    container_name: httpd
    ports:
      - "8083:80"
    volumes:
      - /opt/security:/usr/local/apache2/htdocs


```
*Save and exit*

5. Start the container using docker-compose
```
cd /opt/docker
sudo docker compose up -d

```

6. Verify container is running
```
sudo docker ps

```

7. Test with curl
```
curl http://localhost:8083
```
