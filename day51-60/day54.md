# Task 54
> We are working on an application that will be deployed on multiple containers within a pod on Kubernetes cluster. There is a requirement to share a volume among the containers to save some temporary data. The Nautilus DevOps team is developing a similar template to replicate the scenario. Below you can find more details about it.
>
> Create a pod named volume-share-xfusion.
>
> **For the first container, use image ubuntu with latest tag only and remember to mention the tag i.e ubuntu:latest, container should be named as volume-container-xfusion-1, and run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/media.**
> 
> For the second container, use image ubuntu with the latest tag only and remember to mention the tag i.e ubuntu:latest, container should be named as volume-container-xfusion-2, and again run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/apps.
> Volume name should be volume-share of type emptyDir.
>
> After creating the pod, exec into the first container i.e volume-container-xfusion-1, and just for testing create a file media.txt with any content under the mounted path of first container i.e /tmp/media.
>
> The file media.txt should be present under the mounted path /tmp/apps on the second container volume-container-xfusion-2 as well, since they are using a shared volume.
>
> Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>


### Share a Volume for two containers in a Pod

1. Create the Pod YAML

Create a file named volume-share-xfusion.yaml with the following content:Inspect the Pod
```
apiVersion: v1
kind: Pod
metadata:
  name: volume-share-xfusion
spec:
  containers:
    - name: volume-container-xfusion-1
      image: ubuntu:latest
      command: ["sleep", "3600"]
      volumeMounts:
        - name: volume-share
          mountPath: /tmp/media

    - name: volume-container-xfusion-2
      image: ubuntu:latest
      command: ["sleep", "3600"]
      volumeMounts:
        - name: volume-share
          mountPath: /tmp/apps

  volumes:
    - name: volume-share
      emptyDir: {}
```

*Apply it*
```
kubectl apply -f volume-share-xfusion.yaml
```

*Verfiy Pod is running*
```
kubectl get pods
```

2. Exec into first container and create file
```
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-1 -- bash
```

*Inside the container*
```
echo "Hello shared volume!" > /tmp/media/media.txt
ls -l /tmp/media
exit
```

3. Check the file in second container

```
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-2 -- bash
```
*Inside the container*
```
ls -l /tmp/apps
cat /tmp/apps/media.txt
exit
```

*expected output inside container 2*
```
media.txt
Hello shared volume!
```

