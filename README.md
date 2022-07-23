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