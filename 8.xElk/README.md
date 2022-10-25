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

# ELK console commands
```sql
GET _search
{
  "query": {
    "match_all": {}
  }
}

GET api/data_views/data_view/my-view/runtime_field/foo

GET akaprod/_mapping/field/destination.geo.timezone

POST akaprod/_mapping
{
    "destination.geo.timezone": {
        "full_name": "destination.geo.timezone",
        "mapping": {
            "timezone": {
                "type": "keyword"
            }
        }
    }
}
```
