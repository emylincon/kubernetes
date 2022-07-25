# send ddata to kibana
* structure
```bash

curl http://elasticsearchnode/index_name/_create -H 'Content-Type: application/json' -d @data.json
```
* example
```bash
curl http://localhost:9200/securityinfo/_create -H 'Content-Type: application/json' -d @data.json
```
or
```bash
curl http://localhost:9200/securityinfo/_doc -H 'Content-Type: application/json' -d @data.json
```

* data structure for `data.json`
```json

{
	"@timestamp": "2021-01-05T10:10:10",
	"message":"protocol port mis-match",
	"dst":{
		"ip": "192.168.1.56",
		"port":"88"
	}
}
```

## Dev tools
* use devtools to create index
```
PUT /securityinfo
```
* post data to new index
```
POST /securityinfo/_doc 
{
	"@timestamp": "2021-01-05T10:10:10",
	"message":"protocol port mis-match",
	"dst":{
		"ip": "192.168.1.56",
		"port":"88"
	}
}
```