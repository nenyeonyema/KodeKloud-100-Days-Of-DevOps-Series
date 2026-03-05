# Task 61
> There are some applications that need to be deployed on Kubernetes cluster and these apps have some pre-requisites where some configurations need to be changed before deploying the app container. Some of these changes cannot be made inside the images so the DevOps team has come up with a solution to use init containers to perform these tasks during deployment. Below is a sample scenario that the team is going to test first.
>
> Create a Deployment named as ic-deploy-datacenter.
>
> Configure spec as replicas should be 1, labels app should be ic-datacenter, template's metadata lables app should be the same ic-datacenter.
>
> The initContainers should be named as ic-msg-datacenter, use image ubuntu with latest tag and use command '/bin/bash', '-c' and 'echo Init Done - Welcome to xFusionCorp Industries > /ic/ecommerce'. The volume mount should be named as ic-volume-datacenter and mount path should be /ic.
>
> Main container should be named as ic-main-datacenter, use image ubuntu with latest tag and use command '/bin/bash', '-c' and 'while true; do cat /ic/ecommerce; sleep 5; done'. The volume mount should be named as ic-volume-datacenter and mount path should be /ic.
>
> Volume to be named as ic-volume-datacenter and it should be an emptyDir type.
>
> Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>

### Create a Deployment with a Replica (initContainer and the maincontainer )

1. ic-deploy-datacenter.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ic-deploy-datacenter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ic-datacenter
  template:
    metadata:
      labels:
        app: ic-datacenter
    spec:
      initContainers:
      - name: ic-msg-datacenter
        image: ubuntu:latest
        command: ["/bin/bash", "-c", "echo Init Done - Welcome to xFusionCorp Industries > /ic/ecommerce"]
        volumeMounts:
        - name: ic-volume-datacenter
          mountPath: /ic

      containers:
      - name: ic-main-datacenter
        image: ubuntu:latest
        command: ["/bin/bash", "-c", "while true; do cat /ic/ecommerce; sleep 5; done"]
        volumeMounts:
        - name: ic-volume-datacenter
          mountPath: /ic

      volumes:
      - name: ic-volume-datacenter
        emptyDir: {}
```

2. Apply it
```
kubectl apply -f ic-deploy-datacenter.yaml
```

3. Verify
*Check if InitContainer ran successfully*
```
kubectl get pods
kubectl describe pod -l app=ic-datacenter
```

*Check output from the main container*
```
kubectl logs -f -l app=ic-datacenter
```
