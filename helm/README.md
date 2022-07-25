# Notes onn helm
`Helm` is like a package manager for k8.

## Useful commands
* install k8 package chart
```bash
helm install --values --name
```
* fetch package without installation
```bash
helm fetch <pkg>
```
* list all helm charts
```bash
helm list
```
* delete chart
```bash
helm delete <chart>
```