# Task 64
> One of the DevOps engineers was trying to deploy a python app on Kubernetes cluster. Unfortunately, due to some mis-configuration, the application is not coming up. Please take a look into it and fix the issues. Application should be accessible on the specified nodePort.
>
> The deployment name is python-deployment-devops, its using poroko/flask-demo-appimage. The deployment and service of this app is already deployed.
>
> nodePort should be 32345 and targetPort should be python flask app's default port.
>
> Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.
>

### FIX: Python Flask App Not Coming Up on Kubernetes

1. Check the Deployment
The default Flask port is 5000, but the container or service might be using the wrong containerPort or targetPort.

Run:
```
kubectl describe deployment python-deployment-devops
```

*Look under containers → ports.*

If you see anything other than 5000, that is the misconfiguration.

Fix it:
```
kubectl edit deployment python-deployment-devops
```

Set:
```
ports:
  - containerPort: 5000
```

2. Check the Service
Now confirm the Service is exposing the correct nodePort and targetPort.

```
kubectl edit svc python-deployment-devops
```
Correct and Fix the Ports to:
```
ports:
- port: 5000
  targetPort: 5000
  nodePort: 32345
  protocol: TCP
```
3. Restart Pods
If the old pod still uses wrong configs:
```
kubectl delete pod -l app=python-deployment-devops
```
Deployment will automatically recreate them correctly.

4. Test Access
Get node IP:

```
kubectl get nodes -o wide
```

Then open in browser:
```
http://<NODE-IP>:32345
```
