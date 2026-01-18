# Create Custom ConfigMaps
This is a simple example of how to create custom configmaps in k8s.

The custom controller will watch for changes to the custom resource and create/update/delete the configmap accordingly.

The custom controller is a python script that uses the kubernetes python client to watch for changes to the custom resource.

The custom controller is deployed as a deployment in k8s.

## Prerequisites
* kubectl
* python3
* kubernetes python client
* docker
* minikube or other k8s cluster

## Resources
* [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
* [Kubernetes Custom Resource Definitions](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#customresourcedefinition-v1-apiextensions-k8s-io)
* [Kubernetes Python Client](https://github.com/kubernetes-client/python)

## Reference
The steps in this example are based on the following [this blog post](https://medium.com/@muppedaanvesh/a-hand-on-guide-to-kubernetes-custom-resource-definitions-crds-with-a-practical-example-%EF%B8%8F-84094861e90b).

## Create the custom controller
* create custom controller
```bash
kubectl apply -f controller-deployment.yaml
```
* check custom controller
```bash
kubectl get pods
```
output:
```bash
NAME                                  READY   STATUS    RESTARTS   AGE
custom-controller-6444444444-44444   1/1     Running   0          10s
```


## Create the Custom Resource Definition (CRD)
* create custom resource definition
```bash
kubectl apply -f configmap-custom-resource-definition.yaml
```
* check custom resource definition
```bash
kubectl get crd
```
output:
```bash
NAME                      CREATED AT
customconfigmaps.emeka.com   2026-01-18T10:00:00Z
```
## Create the Custom Resource (CR)
* create custom resource with the custom resource definition
```bash
kubectl apply -f custom-configmap.yaml
```
* check custom configmap
```bash
kubectl get customconfigmaps
```
* can optionally use the short name
```bash
kubectl get ccm
```
output:
```bash
NAME                         AGE
my-custom-resource-instance  10s
```
* expose k8s proxy
```bash
kubectl proxy
```
* check custom configmap with curl
```bash
curl http://localhost:8001/apis/emeka.com/v1/namespaces/default/customconfigmaps
```
output:
```json
{
  "apiVersion": "emeka.com/v1",
  "items": [
    {
      "apiVersion": "emeka.com/v1",
      "kind": "CustomConfigMap",
      "metadata": {
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"emeka.com/v1\",\"kind\":\"CustomConfigMap\",\"metadata\":{\"annotations\":{},\"name\":\"my-custom-resource-instance\",\"namespace\":\"default\"},\"spec\":{\"my-own-property\":\"My first CRD instance\"}}\n"
        },
        "creationTimestamp": "2026-01-18T09:40:43Z",
        "generation": 1,
        "managedFields": [
          {
            "apiVersion": "emeka.com/v1",
            "fieldsType": "FieldsV1",
            "fieldsV1": {
              "f:metadata": {
                "f:annotations": {
                  ".": {},
                  "f:kubectl.kubernetes.io/last-applied-configuration": {}
                }
              },
              "f:spec": {
                ".": {},
                "f:my-own-property": {}
              }
            },
            "manager": "kubectl-client-side-apply",
            "operation": "Update",
            "time": "2026-01-18T09:40:43Z"
          }
        ],
        "name": "my-custom-resource-instance",
        "namespace": "default",
        "resourceVersion": "3628",
        "uid": "5807462c-bf7c-4e17-a47d-44439ab3a70b"
      },
      "spec": {
        "my-own-property": "My first CRD instance"
      }
    }
  ],
  "kind": "CustomConfigMapList",
  "metadata": {
    "continue": "",
    "resourceVersion": "3674"
  }
}
```
* check configmap
```bash
kubectl get configmap
```
output:
```bash
NAME                         DATA   AGE
my-custom-resource-instance  1      10s
```
* delete custom configmap
```bash
kubectl delete -f custom-configmap.yaml
```
* check configmap
```bash
kubectl get configmap
```
output:
```bash
No resources found in default namespace.
```

## Cleanup
* delete custom controller
```bash
kubectl delete -f controller-deployment.yaml
```
* delete custom resource definition
```bash
kubectl delete -f configmap-custom-resource-definition.yaml
```
