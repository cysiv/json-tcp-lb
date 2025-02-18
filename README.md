# json tcp lb

[![Docker Automated Build](https://img.shields.io/docker/cloud/automated/corelight/json-tcp-lb.svg)](https://cloud.docker.com/repository/docker/corelight/json-tcp-lb/builds)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/corelight/json-tcp-lb.svg)](https://cloud.docker.com/repository/docker/corelight/json-tcp-lb/builds)


This is a simple line based tcp load balancing proxy.  It is designed to work with newline
delimited json, but will work with any line based protocol.

This is different from a basic TCP proxy in that it will load balance data in a
single connection across multiple destinations.

## Features

* Load balancing to multiple connections across multiple targets.
* Failed transmissions will be retried to avoid ever losing data.
* Target failover and failback.

## Implementation

* The proxy will start up N worker `connections` to each `target`.
* The proxy will read data from the incoming connection into a 16KiB buffer.
* The buffer will be split cleanly on a newline boundary, or combined with additional data until at least one newline is seen.
* The buffer containing one or more lines is places onto a channel and will be pulled by a worker and transmitted to a target.
* If any of the worker connections fail, it will attempt to connect to a random target instead.
* Every 5 minutes it will reconnect (and to its original target if it failed over to a random target previously).

## Usage

    Usage of ./json-tcp-lb:
      -addr string
            Address to listen on (default "0.0.0.0")
      -port int
            Port to listen on (default 9000)
      -target string
            Address to proxy to. separate multiple with comma (default "127.0.0.1:9999")
      -connections int
            Number of outbound connections to make to each target (default 4)
      -debug true
            Enable debug logging and listen to pprof on :8080

## Container Usage

The `Dockerfile` can be used to build the tcp lb in a container, then run like the following example:
```bash
docker build -t json-tcp-lb .
docker run -p ${LISTEN_PORT}:${LISTEN_PORT} -target ${TARGET_STRING} json-tcp-lb
```

## Alternatives

I'm not aware of any simple alternatives.  This is similar to something like
gRPC load balancing across a single http/2 session in something like Envoy.
It's likely possible to add 'newline delimited' data as a codec in Envoy or
another load balancer.
