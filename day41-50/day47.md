# Task 47
> A python app needed to be Dockerized, and then it needs to be deployed on App Server 2. We have already copied a requirements.txt file (having the app dependencies) under /python_app/src/ directory on App Server 2. Further complete this task as per details mentioned below:
>
>
> **Create a Dockerfile under /python_app directory:**
>
> * Use any python image as the base image.
> * Install the dependencies using requirements.txt file.
> * Expose the port 8084.
> * Run the server.py script using CMD.
>
> Build an image named nautilus/python-app using this Dockerfile.
>
> Once image is built, create a container named pythonapp_nautilus:
>
> Map port 8084 of the container to the host port 8097.
>
> Once deployed, you can test the app using curl command on App Server 2.
>
> curl http://localhost:8097/


### Dockerizing and Deploying a Python Application — End-to-End

1. SSH into App server 2
```
ssh steve@stapp02

```

2. Navigate to the Dockerfile
```
cd /python_app
```

3. Create the Dockerfile

```
vi Dockerfile
```

**Content of the Dockerfile**

```
FROM python:3.9

WORKDIR /app

COPY src/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 8084

CMD ["python", "server.py"]

```
*Save and exit*

4. Test the Dockerfile by building an image

```
docker build -t nautilus/python-app .
```

5. Run the container
```
docker run -d --name pythonapp_nautilus -p 8097:8084 nautilus/python-app

```
*Confirm is runnig*
```
docker ps
```

6. Test application
```
curl http://localhost:8097/

```
