# Task 58
> The Nautilus DevOps teams is planning to set up a Grafana tool to collect and analyze analytics from some applications. They are planning to deploy it on Kubernetes cluster. Below you can find more details. 
> * Create a deployment named grafana-deployment-xfusion using any grafana image for Grafana app. Set other parameters as per your choice.
> * Create NodePort type service with nodePort 32000 to expose the app.
>
> You need not to make any configuration changes inside the Grafana app once deployed, just make sure you are able to access the Grafana login page.
>
> Note: The kubectl on jump_host has been configured to work with kubernetes cluster.
>


### Create a Grafana Deployment with NodePort Service

1. Deployment (grafana-deployment-xfusion.yaml)

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-deployment-xfusion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
```

2. AService (grafana-service.yaml)
```
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 32000
```

2. Apply the resources
```
kubectl apply -f grafana-deployment-xfusion.yaml
kubectl apply -f grafana-service.yaml
```

*Check deployment and pod*
```
kubectl get pods -o wide
kubectl get deployment
```

*Check Service*
```
kubectl get svc
```

3. Accss Grafana
Open in Browser
```
http://<NODE-IP>:32000
```
