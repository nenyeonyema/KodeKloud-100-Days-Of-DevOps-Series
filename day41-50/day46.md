# Task 46
> The Nautilus Application development team recently finished development of one of the apps that they want to deploy on a containerized platform. The Nautilus Application development and DevOps teams met to discuss some of the basic pre-requisites and requirements to complete the deployment.
> The team wants to test the deployment on one of the app servers before going live and set up a complete containerized stack using a docker compose fie. Below are the details of the task:
>
>
> On App Server 3 in Stratos Datacenter create a docker compose file /opt/data/docker-compose.yml (should be named exactly).
>
> The compose should deploy two services (web and DB), and each service should deploy a container as per details below:
>
> For web service:
>
> * Container name must be php_blog.
>
> * Use image php with any apache tag. Check here for more details.
>
> * Map php_blog container's port 80 with host port 5003
>
> * Map php_blog container's /var/www/html volume with host volume /var/www/html.
>
> For DB service:
>
> Container name must be mysql_blog.
>
> * Use image mariadb with any tag (preferably latest). Check here for more details.
>
> * Map mysql_blog container's port 3306 with host port 3306
>
> * Map mysql_blog container's /var/lib/mysql volume with host volume /var/lib/mysql.
>
> * Set MYSQL_DATABASE=database_blog and use any custom user ( except root ) with some complex password for DB connections.
>
> After running docker-compose up you can access the app with curl command curl <server-ip or hostname>:5003/


### Building a Multi-Service Stack with Docker Compose 

1. SSH into App server 3
```
ssh banner@stapp03

```

2. Navigate to the Dockerfile
```
cd /opt/data
```

3. Create a `docker-compose.yml` file
```
vi docker-compose.yml
```

**Content of the docker-compose.yml file**

```
version: '3'

services:
  web:
    container_name: php_blog
    image: php:apache
    ports:
      - "5003:80"
    volumes:
      - /var/www/html:/var/www/html
    depends_on:
      - db
    networks:
      - app-network

  db:
    container_name: mysql_blog
    image: mariadb:latest
    ports:
      - "3306:3306"
    volumes:
      - /var/lib/mysql:/var/lib/mysql
    environment:
      MYSQL_DATABASE: database_blog
      MYSQL_USER: blog_user
      MYSQL_PASSWORD: SecureP@ssw0rd123!
      MYSQL_ROOT_PASSWORD: RootP@ssw0rd456!
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```
*Save and exit*

**Create the host volume directories**

```
sudo mkdir -p /var/www/html
sudo mkdir -p /var/lib/mysql
```


4. Start the docker-compose stack
```
sudo docker-compose up -d
```

*Confirm is runnig*
```
docker ps
```

6. Test with curl
```
curl localhost:5003/
# or
curl <server-ip>:5003/
```
