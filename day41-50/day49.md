# Task 49
> The Nautilus DevOps team is delving into Kubernetes for app management. One team member needs to create a deployment following these details:
>
>
> **Create a deployment named httpd to deploy the application httpd using the image httpd:latest (ensure to specify the tag)**
>
> 
> Note: The kubectl utility on jump_host is set up to interact with the Kubernetes cluster.
>
>


### Create a deployment named httpd

1. On the jumphost create a Yaml file

```
vi httpd-deployment.yaml
```
Yaml file content
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
        - name: httpd
          image: httpd:latest

```

2. Then Apply it
```
kubectl apply -f httpd-deployment.yaml
```


*verify*

```
kubectl get deployments
kubectl get pods -l app=httpd
```
