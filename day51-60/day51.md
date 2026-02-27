# Task 51
> An application currently running on the Kubernetes cluster employs the nginx web server. The Nautilus application development team has introduced some recent changes that need deployment. They've crafted an image nginx:1.19 with the latest updates.
>
> **Execute a rolling update for this application, integrating the nginx:1.19 image. The deployment is named nginx-deployment.**
> 
> Ensure all pods are operational post-update.
>
> Note: The kubectl utility on jump_host is set up to operate with the Kubernetes cluster
>


### Perform a Rolling Update

1. On the jumphost run the rolling update

```
kubectl set image deployment/nginx-deployment nginx=nginx:1.19
```

If the container name is different, check with
```
kubectl get deployment nginx-deployment -o yaml | grep image
```

2. Verify Rollout status
```
kubectl rollout status deployment/nginx-deployment
```

*Verify the new rolled out image version*

```
kubectl describe deployment nginx-deployment | grep Image
```
