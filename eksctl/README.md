# eksctl Notes
* [EKSCTL](https://eksctl.io/introduction/#getting-started)
* [eksctl-github](https://github.com/weaveworks/eksctl)

# create basic cluster
```bash
eksctl create cluster --name=emeka-eksctl --nodes=2 --region=eu-central1 
```
* example:
```bash
eksctl create cluster --name emeka-eksctl --nodes 3 --region eu-central-1 node-type t2.micro
```
* example:
```bash
eksctl create cluster -f cluster.yaml

```

* get cluster credentials
```bash
eksctl utils write-kubeconfig --cluster=<name> [--kubeconfig=<path>][--set-kubeconfig-context=<bool>]
```

* delete cluster
```bash
eksctl delete cluster --name=<name> [--region=<region>]
```
* example:
```bash
eksctl delete cluster -f cluster.yaml

```