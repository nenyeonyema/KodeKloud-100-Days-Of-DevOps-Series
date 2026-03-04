# Task 53
> We encountered an issue with our Nginx and PHP-FPM setup on the Kubernetes cluster this morning, which halted its functionality. Investigate and rectify the issue:
>
> The pod name is nginx-phpfpm and configmap name is nginx-config. Identify and fix the problem.
>
> **Once resolved, copy /home/thor/index.php file from the jump host to the nginx-container within the nginx document root. After this, you should be able to access the website using Website button on the top bar.**
> 
> Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.
>


### Debugging, fixing a configMap, restarting the pod, and copying a PHP file into the container.

1. Inspect the Pod
```
kubectl describe pod nginx-phpfpm
kubectl logs nginx-phpfpm -c nginx-container
kubectl logs nginx-phpfpm -c phpfpm-container
```

2. Check the ConfigMap nginx-config
```
kubectl get configmap nginx-config -o yaml
```

*Correct Config should be:* 
```
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

3. Correct the Config map

```
kubectl edit configmap nginx-config
```
4. Restart the Pod to Apply ConfigMap Changes
ConfigMaps do not update live inside a pod unless you restart it.

Delete the pod:
```
kubectl delete pod nginx-phpfpm
```

The deployment/statefulset will recreate it automatically.
Wait for it:

```
kubectl get pods
```

You should see:
```
nginx-phpfpm   Running
```

5. Copy index.php into the nginx container
First check containers:
```
kubectl get pod nginx-phpfpm -o jsonpath='{.spec.containers[*].name}'
```

*Now copy the file*
```
kubectl cp /home/thor/index.php nginx-phpfpm:/usr/share/nginx/html/index.php -c nginx-container
```

6. Verify from inside the Container
```
kubectl exec -it nginx-phpfpm -c nginx-container -- ls -l /usr/share/nginx/html
```

*Test Using the Website Button*
