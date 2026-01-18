# CRDs
* create crd
```bash
kubectl apply -f cron-crds.yaml
```
* list all custom resource definitions
```bash
kubectl get crd
```
* check crd
```bash
kubectl get crontabs
```
* view crd yaml file
```bash
kubectl get crd crontabs.stable.example.com -o yaml
```
* expose k8s proxy
```bash
kubectl proxy
```
* check crd
```bash
curl http://localhost:8001/apis/stable.example.com/v1/namespaces/default/crontabs
```
output:
```json
{
  "apiVersion": "stable.example.com/v1",
  "items": [],
  "kind": "CronTabList",
  "metadata": {
    "continue": "",
    "resourceVersion": "1821"
  }
}
```
* create cron tab
```bash
kubectl apply -f my-crontab.yaml
```
* check cron tab
```bash
kubectl get crontabs
```
output:
```bash
NAME               AGE
my-new-cron-object 10s
```
* check cron tab with curl
```bash
curl http://localhost:8001/apis/stable.example.com/v1/namespaces/default/crontabs

```
output:
```json
{
  "apiVersion": "stable.example.com/v1",
  "items": [
    {
      "apiVersion": "stable.example.com/v1",
      "kind": "CronTab",
      "metadata": {
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"stable.example.com/v1\",\"kind\":\"CronTab\",\"metadata\":{\"annotations\":{},\"name\":\"my-new-cron-object\",\"namespace\":\"default\"},\"spec\":{\"cronSpec\":\"* * * * */5\",\"image\":\"my-awesome-cron-image\"}}\n"
        },
        "creationTimestamp": "2026-01-18T09:04:25Z",
        "generation": 1,
        "managedFields": [
          {
            "apiVersion": "stable.example.com/v1",
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
                "f:cronSpec": {},
                "f:image": {}
              }
            },
            "manager": "kubectl-client-side-apply",
            "operation": "Update",
            "time": "2026-01-18T09:04:25Z"
          }
        ],
        "name": "my-new-cron-object",
        "namespace": "default",
        "resourceVersion": "1873",
        "uid": "b11124ea-8e08-4d96-a5f0-d98f3d421d0a"
      },
      "spec": {
        "cronSpec": "* * * * */5",
        "image": "my-awesome-cron-image"
      }
    }
  ],
  "kind": "CronTabList",
  "metadata": {
    "continue": "",
    "resourceVersion": "1892"
  }
}
```
* delete crd
```bash
kubectl delete crd crontabs.stable.example.com
```
The above will also delete all crontabs.