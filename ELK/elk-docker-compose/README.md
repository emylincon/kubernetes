* create index
```
PUT emekaindex
```
*  add data to index
```
PUT emekaindex/_doc/1
{
  "@timestamp": "2021-01-05T10:10:10",
  "message": "first message",
  "dst": {
    "ip": "192.168.1.1",
    "port": "80"
  },
  "body": "here"
}


```
* logstash s3

```conf
  s3 {
    bucket => "emeka-s3-logstash-input"
     id => "s3_plugin_id"
   }
```