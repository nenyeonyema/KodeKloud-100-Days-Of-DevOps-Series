---
**Task 37**
The Nautilus DevOps team possesses confidential data on App Server 2 in the Stratos Datacenter. A container named ubuntu_latest is running on the same server.



Copy an encrypted file /tmp/nautilus.txt.gpg from the docker host to the ubuntu_latest container located at /usr/src/. Ensure the file is not modified during this operation.
---

### TASK 37: Copy an Encrypted file from Docker host into the Running Container

1. Check running containers
```
docker ps
```
Confirm that ubuntu_latest is running, get its name or ID

2. Copy file into the container
Use docker cp which preserves file contents exactly.

```
docker cp /tmp/nautilus.txt.gpg ubuntu_latest:/usr/src/

```

3. Verify inside the container

```
docker exec -it ubuntu_latest ls -l /usr/src/

```

You should see:

```
nautilus.txt.gpg

```

