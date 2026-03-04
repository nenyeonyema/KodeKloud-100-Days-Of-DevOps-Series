# Task 57
> The Nautilus DevOps team is working on to setup some pre-requisites for an application that will send the greetings to different users. There is a sample deployment, that needs to be tested. Below is a scenario which needs to be configured on Kubernetes cluster. Please find below more details about it.
>
>
> Create a pod named print-envars-greeting.
>
> Configure spec as, the container name should be print-env-container and use bash image.
>
> Create three environment variables:

> * GREETING and its value should be Welcome to
>
> * COMPANY and its value should be xFusionCorp
>
> * GROUP and its value should be Industries
>
> Use command ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"'] (please use this exact command), also set its restartPolicy policy to Never to avoid crash loop back.
>
> You can check the output using kubectl logs -f print-envars-greeting command.
>
>Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
>

### Create three environment variables in Pod container spec

1. Correct Pod YAML with name print-envs.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: print-envars-greeting
spec:
  restartPolicy: Never
  containers:
    - name: print-env-container
      image: bash:latest
      command: ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"']
      env:
        - name: GREETING
          value: "Welcome to"
        - name: COMPANY
          value: "xFusionCorp"
        - name: GROUP
          value: "Industries"
```

2. Apply it
```
kubectl apply -f print-envs.yaml
```

*See logs* 
```
kubectl logs -f print-envars-greeting
```

*Output*
```
Welcome to xFusionCorp Industries
```
