# Task 59
> Last week, the Nautilus DevOps team deployed a redis app on Kubernetes cluster, which was working fine so far. This morning one of the team members was making some changes in this existing setup, but he made some mistakes and the app went down. We need to fix this as soon as possible. Please take a look.
> The deployment name is redis-deployment. The pods are not in running state right now, so please look into the issue and fix the same.
>
>Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>
>


### Fix a Redis Deployment issue

1. Troubleshoot for the issue
*Check the pod status*

```
kubectl get pods
```

*Inspect pod logs*
```
kubectl logs -l app=redis
```

*Check the deployment*
```
kubectl describe deployment redis-deployment
```

*Inspect the pod*
```
kubectl describe pod <pod-name>
```
2. Errrors Identified
* Wrong Image name
```
redis:alpin
```
Correct image name:
```
redis:alpine
```
* Wrong ConfigMap name
```
Name: redis-cofig
```
Correct ConfigMap Name:
```
redis-config
```

3. Fix the errors with the correct image name and ConfigMap name
*Edit the Deployment*
```
kubectl edit deployment redis-deployment
```
**Correct image name:**
```
redis:alpine
```

**Correct ConfigMap Name:**
```
redis-config
```


4. Verify
```
kubectl get pods
kubectl describe pod -l app=redis
kubectl logs -l app=redis
```
