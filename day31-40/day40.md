---
**Task 40**
One of the Nautilus DevOps team members was working to configure services on a kkloud container that is running on App Server 1 in Stratos Datacenter. Due to some personal work he is on PTO for the rest of the week, but we need to finish his pending work ASAP. Please complete the remaining work as per details given below:


a. Install apache2 in kkloud container using apt that is running on App Server 1 in Stratos Datacenter.


b. Configure Apache to listen on port 6200 instead of default http port. Do not bind it to listen on specific IP or hostname only, i.e it should listen on localhost, 127.0.0.1, container ip, etc.


c. Make sure Apache service is up and running inside the container. Keep the container in running state at the end.

---

### TASK 40: Configure Apache Inside a Running Container

1. SSH into App Server 1
Use the credentials provided for the KodeKloud lab:
```
ssh tony@stapp01
```
Switch to root:
```
sudo -i
```
2. Verify container name
```
docker ps
```

3. Install apache2 inside the kkloud container

Run:
```
docker exec -it kkloud apt-get update
docker exec -it kkloud apt-get install apache2 -y

```

4. Configure Apache to listen on port 6200
Apache’s ports file is located at: `/etc/apache2/ports.conf`

Edit inside the container
```
docker exec -it kkloud bash

```
Then inside the container
```
sed -i 's/Listen 80/Listen 6200/' /etc/apache2/ports.conf

```
Also edit the default site settings
```
sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:6200>/' /etc/apache2/sites-enabled/000-default.conf
```
Make sure no IP is specified, it should be:

```
Listen 6200
<VirtualHost *:6200>
```
Exit the container
```
exit
```

5. Start Apache service inside the container
```
docker exec -it kkloud service apache2 start
```
Verify:
```
docker exec -it kkloud service apache2 status
```
You should see active (running)

Also confirm Apache is listening on port 6200
```
docker exec -it kkloud ss -tulnp | grep 6200

```
