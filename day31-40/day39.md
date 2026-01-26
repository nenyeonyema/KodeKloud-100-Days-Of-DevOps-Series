---
**Task 39**
One of the Nautilus developer was working to test new changes on a container. He wants to keep a backup of his changes to the container. A new request has been raised for the DevOps team to create a new image from this container. Below are more details about it:


a. Create an image news:xfusion on Application Server 1 from a container ubuntu_latest that is running on same server.

---

### TASK 39: Create an Image from a Running Container

1. Confirm the running container name

```
docker ps
```

You should see a container named ubuntu_latest.

2. Commit the Container into a new Image 
```
docker commit ubuntu_latest news:xfusion

```

3. Verify the new Image exist

```
docker images | grep news

```
