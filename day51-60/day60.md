# Task 60
> The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster. There are some requirements to create/use persistent volumes to store the application code, and the template needs to be designed accordingly. Please find more details below:
>
> Create a PersistentVolume named as pv-devops. Configure the spec as storage class should be manual, set capacity to 5Gi, set access mode to ReadWriteOnce, volume type should be hostPath and set path to /mnt/finance (this directory is already created, you might not be able to access it directly, so you need not to worry about it).
>
> Create a PersistentVolumeClaim named as pvc-devops. Configure the spec as storage class should be manual, request 3Gi of the storage, set access mode to ReadWriteOnce.
>
> Create a pod named as pod-devops, mount the persistent volume you created with claim name pvc-devops at document root of the web server, the container within the pod should be named as container-devops using image nginx with latest tag only (remember to mention the tag i.e nginx:latest).
>
> Create a node port type service named web-devops using node port 30008 to expose the web server running within the pod.
>
> Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>

### Create a Persistent Volume and persistent Volume Claim  


1. PersistentVolume (pv-devops.yaml)
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-devops
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/finance
```

2. PersistentVolumeClaim (pvc-devops.yaml)
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-devops
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

3. Pod (pod-devops.yaml)

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-devops
  labels:
    app: nginx-app
spec:
  containers:
  - name: container-devops
    image: nginx:latest
    ports:
    - containerPort: 80
    volumeMounts:
    - name: web-content
      mountPath: /usr/share/nginx/html
  volumes:
  - name: web-content
    persistentVolumeClaim:
      claimName: pvc-devops
```

4. Service (web-devops.yaml)

```
apiVersion: v1
kind: Service
metadata:
  name: web-devops
spec:
  type: NodePort
  selector:
    app: nginx-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30008
```

5. Apply it all
```
kubectl apply -f pv-devops.yaml
kubectl apply -f pvc-devops.yaml
kubectl apply -f pod-devops.yaml
kubectl apply -f web-devops.yaml
```
