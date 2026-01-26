---
**Task 38**

Nautilus project developers are planning to start testing on a new project. As per their meeting with the DevOps team, they want to test containerized environment application features. As per details shared with DevOps team, we need to accomplish the following task:


a. Pull busybox:musl image on App Server 2 in Stratos DC and re-tag (create new tag) this image as busybox:media.

---

### TASK 38: Pull a busybox:musl Image and re-tag the Image to busybox:media

1. Pull the busybox:musl image
```
docker pull busybox:musl
```

2. Re-tag the image as busybox:media

```
docker pull busybox:musl
```

3. Verify the new tag

```
docker images | grep busybox
```
