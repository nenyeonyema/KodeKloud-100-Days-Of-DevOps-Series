# Task 43
> The Nautilus DevOps team is planning to host an application on a nginx-based container. There are number of tickets already been created for similar tasks. One of the tickets has been assigned to set up a nginx container on Application Server 3 in Stratos Datacenter. Please perform the task as per details mentioned below:
> * Pull nginx:alpine-perl docker image on Application Server 3.
> * Create a container named games using the image you pulled.
> * Map host port 8083 to container port 80. Please keep the container in running state.


### Pull Nginx Image, create a container named games and map host port to container port 

1. SSH into App server 3
```
ssh banner@stapp03

```

2. Pull the required image
```
docker pull nginx:alpine-perl

```
3. Create the container named games

Map host port 8083 → container port 80:

```
docker run -d --name games -p 8083:80 nginx:alpine-perl

```

4. Confirm the container is running
```
docker ps

```

5. Test
```
curl http://localhost:8083

```

*You’ll get the default nginx welcome page HTML.*
