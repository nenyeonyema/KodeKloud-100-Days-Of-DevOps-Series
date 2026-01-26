# Task 36
> The Nautilus DevOps team is conducting application deployment tests on selected application servers. They require a nginx container deployment on Application Server 2. 
> Complete the task with the following instructions:


> On Application Server 2 create a container named nginx_2 using the nginx image with the alpine tag. Ensure container is in a running state.


### TASK 36: Run an Nginx Container of Alpine Version

1. SSH into App Server 2
Use the credentials provided for the KodeKloud lab:
```
ssh steve@stapp02
```
Switch to root:
```
sudo -i
```
2. Pull the nginx:alpine Image

```
docker pull nginx:alpine
```

3. Run the Container Named nginx_2

```
docker run -d --name nginx_2 -p 80:80 nginx:alpine
```

4. Verify that the Container is running
```
docker ps
```
