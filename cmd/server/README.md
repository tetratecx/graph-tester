# Service

This directory holds the "mock-service" component for isotope. It is a
relatively simple HTTP server which follows instructions from a YAML file and
exposes Prometheus metrics.

## Usage

1. Set the environment variable, `CONFIG_PATH`, to the file containing the entire topology in yaml
1. Set the environment variable, `SERVICE_NAME`, to the name of the service
   from the topology YAML that this service should emulate

Example:

```bash
SERVICE_NAME=b CONFIG_PATH=../example-topologies/chain-2-services-different-namespace.yaml go run main.go
```

The output of that example will show an error since the topology defines that service with name `a`
calls `b.demo2.svc.cluster.local:8080` which does not exist in your local

```bash
❯ curl localhost:8080
Get "http://b.demo2.svc.cluster.local:8080": dial tcp: lookup b.demo2.svc.cluster.local: no such host
```

### Deploy

You can build and deploy the image by your own, or to build and push the image
with [ko](https://github.com/ko-build/ko)
and a [ephemeral registry](https://www.civo.com/learn/ttl-sh-your-anonymous-and-ephemeral-docker-image-registry)
in one command like follows:

```bash
export KO_DOCKER_REPO=ttl.sh/<my-prefix>-isotope-service
ko build --bare -t 1h .
```

## Metrics

Captures the following metrics for a Prometheus endpoint:

- `service_incoming_requests_total` - a counter of requests received by this
  service
- `service_outgoing_requests_total` - a counter of requests sent to other
  services
- `service_outgoing_request_size` - a histogram of sizes of requests sent to
  other services
- `service_request_duration_seconds` - a histogram of durations from "request
  received" to "response sent"
- `service_response_size` - a histogram of sizes of responses sent from this
  service

## Performance

With both a Fortio 1.1.0 client and a single isotope service running in a GKE
cluster, the client on a n1-highcpu-96 machine sending 96 concurrent requests
as fast as possible, the service on a n1-standard-4 machine with a limit of 1
vCPU and 3.75GB RAM, and logging set to INFO, the service reaches a maximum
QPS of 12,000 - 14,000 before maxing out CPU.
