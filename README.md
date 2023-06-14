# Redis-haproxy

## Docker Container Image

```bash
docker pull repigeons/redis-haproxy
```

## Getting Started

Start with command:

```bash
docker run --name redis-haproxy -dp 6379:6379 -e 'REDIS_SERVERS=127.0.0.1:6380,127.0.0.1:6381,127.0.0.1:6382' repigeons/redis-haproxy
```

### Environment variables:

|variable     |type   |required|default|description|example|
|:-----------:|:-----:|:------:|:-----:|:---------:|:-----:|
|REDIS_SERVERS|array  |true    | -     |all redis nodes, including master and slave, splitted with commas.|127.0.0.1:6380,127.0.0.1:6381,127.0.0.1:6382|
|HOST         |string |false   |0.0.0.0|the host to bind.|127.0.0.1|
|PORT         |integer|false   |6379   |the port to listen.|6379|

## Example:

```bash
docker run \
  --restart=always \
  --name=redis-haproxy \
  -dp 6379:6379 \
  -e 'REDIS_SERVERS=192.168.10.11:6379,192.168.10.12:6379,192.168.10.13:6379' \
  -e 'HOST=192.168.10.10' \
  -e 'PORT=6399' \
  repigeons/redis-haproxy
```
