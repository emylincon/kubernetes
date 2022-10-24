# How to run
## Spin up ELK stack
* start docker containers
```bash
docker-compose up -d
```
### Start logger app
* login to logstash container as root
```bash
docker exec -ti -u root logstash bash
```
* cd to app path
```bash
cd /app/
```
* start app
```bash
./app-amd64-linux
```
