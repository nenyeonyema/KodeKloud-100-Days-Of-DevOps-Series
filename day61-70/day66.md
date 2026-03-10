# Task 66

> A new MySQL server needs to be deployed on Kubernetes cluster. The Nautilus DevOps team was working on to gather the requirements. Recently they were able to finalize the requirements and shared them with the team members to start working on it. Below you can find the details:
>
> 1. Create a PersistentVolume mysql-pv, its capacity should be 250Mi, set other parameters as per your preference.
>
> 2. Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as mysql-pv-claim and request a 250Mi of storage. Set other parameters as per your preference.
>
> 3. Create a deployment named mysql-deployment, use any mysql image as per your preference. Mount the PersistentVolume at mount path /var/lib/mysql.
>
> 4. Create a NodePort type service named mysql and set nodePort to 30007.
>
> 5. Create a secret named mysql-root-pass having a key pair value, where key is password and its value is YUIidhb667, create another secret named mysql-user-pass having some key pair values, where frist key is username and its value is kodekloud_gem, second key is password and value is B4zNgHA7Ya, create one more secret named mysql-db-url, key name is database and value is kodekloud_db9
>
> 6. Define some Environment variables within the container:
>
> * name: MYSQL_ROOT_PASSWORD, should pick value from secretKeyRef name: mysql-root-pass and key: password
>
> * name: MYSQL_DATABASE, should pick value from secretKeyRef name: mysql-db-url and key: database
>
> * name: MYSQL_USER, should pick value from secretKeyRef name: mysql-user-pass key key: username
>
> * name: MYSQL_PASSWORD, should pick value from secretKeyRef name: mysql-user-pass and key: password
>
> Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>


### Deploy MySQL with PVC, PV, Secrets & NodePort on Kubernetes

1. PersistentVolume (mysql-pv)

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /mnt/mysql-data
```

2. PersistentVolumeClaim (mysql-pv-claim)
Requests: 250Mi

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 250Mi
```

3. Deployment (mysql-deployment)
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:latest
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-root-pass
                  key: password
            - name: MYSQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: mysql-db-url
                  key: database
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: username
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: password
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim
```

4. Secrets
All 3 secrets in one YAML file (mysql-secrets.yml)

```
apiVersion: v1
kind: Secret
metadata:
  name: mysql-root-pass
type: Opaque
stringData:
  password: YUIidhb667
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-user-pass
type: Opaque
stringData:
  username: kodekloud_gem
  password: B4zNgHA7Ya
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-db-url
type: Opaque
stringData:
  database: kodekloud_db9
```
5. 5. Service (mysql — NodePort)
Exposes MySQL on nodePort 30007
```
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 30007
      protocol: TCP
```

6. Apply them all

```
kubectl apply -f mysql-pv.yml
kubectl apply -f mysql-pv-claim.yml
kubectl apply -f mysql-secrets.yaml
kubectl apply -f mysql-deployment.yml
```

7. Verify
```
kubectl get pv
kubectl get pvc
kubectl get pods
kubectl get svc
kubectl describe pod -l app=mysql
```
