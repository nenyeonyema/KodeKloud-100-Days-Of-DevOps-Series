# Task50 
> The Nautilus DevOps team has noticed performance issues in some Kubernetes-hosted applications due to resource constraints. To address this, they plan to set limits on resource utilization. Here are the details:
>
> **Create a pod named httpd-pod with a container named httpd-container. Use the httpd image with the latest tag (specify as httpd:latest). Set the following resource limits:**
>
> * Requests: Memory: 15Mi, CPU: 100m
> * Limits: Memory: 20Mi, CPU: 100m 
> Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.
>
>


### Create Pod With Resource Requests & Limits

1. On the jumphost create a Yaml file

```
vi httpd-pod.yaml
```

Yaml file content
```

apiVersion: v1
kind: Pod
metadata:
  name: httpd-pod
spec:
  containers:
    - name: httpd-container
      image: httpd:latest
      resources:
        requests:
          memory: "15Mi"
          cpu: "100m"
        limits:
          memory: "20Mi"
          cpu: "100m"
```

2. Then Apply it
```
kubectl apply -f httpd-pod.yaml
```


*verify*

```
kubectl get pod httpd-pod
kubectl describe pod httpd-pod
```
