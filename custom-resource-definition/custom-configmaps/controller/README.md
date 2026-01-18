# Custom ConfigMap Controller
## Build the Docker image
* create build context
```bash
docker buildx ls | grep "temp_builder" || docker buildx create --name=temp_builder --platform linux/amd64,linux/arm64
docker buildx use temp_builder
```
* build  & push docker image
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t ugwuanyi/custom-configmap-controller --push .
```
* remove build context
```bash
docker buildx rm temp_builder
```
* build docker image locally
```bash
docker build -t ugwuanyi/custom-configmap-controller .
```
* run docker image
```bash
docker run -it ugwuanyi/custom-configmap-controller
```

## Run locally
* run python script. This will use the local kubeconfig with current context.
```bash
python3 main.py
```
