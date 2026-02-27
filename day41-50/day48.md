# Task 48
> The Nautilus DevOps team is diving into Kubernetes for application management. One team member has a task to create a pod according to the details below:
>
>
> **Create a pod named pod-nginx using the nginx image with the latest tag. Ensure to specify the tag as nginx:latest.**
>
> Set the app label to nginx_app, and name the container as nginx-container.
> 
> Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.
>
>


### Create Pod  named pod-nginx using

1. On the jumphost run:
```
kubectl run pod-nginx \
  --image=nginx:latest \
  --labels=app=nginx_app \
  --restart=Never \
  --port=80 \
  --dry-run=client -o yaml > pod-nginx.yaml

```

2. Then Apply it
```
kubectl apply -f pod-nginx.yaml
```

**OR**

Use a Yaml file

```
vi pod-nginx.yaml
```
*Paste the content of the Yaml file*

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-nginx
  labels:
    app: nginx_app
spec:
  containers:
    - name: nginx-container
      image: nginx:latest
```
*Save and apply*

```
kubectl apply -f pod-nginx.yaml

```

*verify*
```
kubectl get pods -o wide
```
