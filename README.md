# Notes on kubectl
* start cluster with hyperkit
```bash
minikube start --vm-driver=hyperkit
```
* start cluster with docker
```bash
minikube start --vm-driver=docker
```
* start cluster with virtualbox
```bash
minikube start --vm-driver=virtualbox
```

# Note
* default setup is docker which is current set up.

## More Notes
* to edit a deployment
```bash
kubectl edit deployment/nginx-deployment
```
* wide resuklt

```bash
kubectl get pod -o wide
```

* ssh to a pod
```bash
kubectl exec -ti nginx-deployment-66b6c48dd5-bsnzm -- bash 
```
* use minkube to access service
```bash
minikube service --url  my-service 

```

## Namespace
* get namespaces
```bash
kubectl get namespaces
```
* create namespace
```
kubectl create namespace <namespace>
```
* get pods in a namespace
```bash
kubecl get pods -n <namespace>
```
* delete namespace
```bash
kubectl delete namespace <namespace>
```
* get current namespace
```bash
kubectl config view --minify --output 'jsonpath={..namespace}'
```
or 
```bash
kubectl describe sa default | grep Namespace
```
* set namespace
```bash
kubectl config set-context --current --namespace=my-namespace
```
