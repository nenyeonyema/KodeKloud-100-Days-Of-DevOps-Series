# Task 62
> The Nautilus DevOps team is working to deploy some tools in Kubernetes cluster. Some of the tools are licence based so that licence information needs to be stored securely within Kubernetes cluster. Therefore, the team wants to utilize Kubernetes secrets to store those secrets. Below you can find more details about the requirements:
>
> We already have a secret key file official.txt under /opt location on jump host. Create a generic secret named official, it should contain the password/license-number present in official.txt file.
> 
> Also create a pod named secret-devops.
>
> Configure pod's spec as container name should be secret-container-devops, image should be debian with latest tag (remember to mention the tag with image). Use sleep command for container so that it remains in running state. Consume the created secret and mount it under /opt/demo within the container.
>
> To verify you can exec into the container secret-container-devops, to check the secret key under the mounted path /opt/demo. Before hitting the Check button please make sure pod/pods are in running state, also validation can take some time to complete so keep patience.
>
> Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>

### Create Kubernetes Secrets ( pod named secret-devops)

1. Create the Kubernetes Secret from the file

You already have the file: `opt.official.txt`

**So create Secret**
```
kubectl create secret generic official --from-file=official=/opt/official.txt
```
>
> OR
* Base64-encode the license value
```
cat /opt/official.txt | base64
```
*Copy the BASE64 output value*

* Secret YAML (official-secret.yaml)

Replace BASE64_VALUE with your actual base64 output value copied.
```
apiVersion: v1
kind: Secret
metadata:
  name: official
type: Opaque
data:
  official: BASE64_VALUE
```

*Apply it*
```
kubectl apply -f official-secret.yaml
```

2. Create the Pod (secret-devops.yaml)
```
apiVersion: v1
kind: Pod
metadata:
  name: secret-devops
spec:
  containers:
  - name: secret-container-devops
    image: debian:latest
    command: ["/bin/bash", "-c", "sleep infinity"]
    volumeMounts:
    - name: secret-vol
      mountPath: /opt/demo
  volumes:
  - name: secret-vol
    secret:
      secretName: official
```

3. Apply the Pod
```
kubectl apply -f secret-devops.yaml
```

**Verify Pod is running**
```
kubectl get pods
```

**Check if Secret is mounted correctly inside the container**
```
kubectl exec -it secret-devops -- bash
```

*Inside the container run*
```
ls /opt/demo
cat /opt/demo/official
```
