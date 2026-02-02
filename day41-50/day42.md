# Task 42
> The Nautilus DevOps team needs to set up several docker environments for different applications. One of the team members has been assigned a ticket where he has been asked to create some docker networks to be used later. 
> Complete the task based on the following ticket description:

> * Create a docker network named as ecommerce on App Server 2 in Stratos DC.

> * Configure it to use bridge drivers.

> * Set it to use subnet 192.168.0.0/24 and iprange 192.168.0.0/24.

### Create a Docker Network and configure it to use Bridge drivers

1. SSh into App server 2 from jumphost
```
ssh steve@stapp02
```

2. Create the Docker Network
```
docker network create \
  --driver bridge \
  --subnet 192.168.0.0/24 \
  --ip-range 192.168.0.0/24 \
  ecommerce

```
3. Verify the Network 

```
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

```

