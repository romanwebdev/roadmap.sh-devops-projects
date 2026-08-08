# Consul Service Discovery

A small microservices setup demonstrating service registration, DNS-based
service discovery, and service-to-service communication using
[Consul](https://www.consul.io/).

## Architecture

```
                     ┌─────────────┐
   client  ──────>   │   Gateway   │
                     │  (port 8080)│
                     └──────┬──────┘
                            │  DNS query: <service>.service.consul
                            ▼
                     ┌─────────────┐
                     │   Consul    │
                     │ (dev mode)  │
                     │ 8500 (HTTP) │
                     │ 8600 (DNS)  │
                     └──────┬──────┘
                            ▲  register on startup (HTTP API)
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        ┌───────────┐ ┌───────────┐ ┌───────────┐
        │ service-a │ │ service-b │ │ service-c │
        │  :3001    │ │  :3002    │ │  :3003    │
        └───────────┘ └───────────┘ └───────────┘
```

- **service-a / service-b / service-c** — identical Express apps exposing
  `GET /info` (returns service name + timestamp) and `GET /health`. Each
  registers itself with Consul via the HTTP API (`PUT
/v1/agent/service/register`) on startup, including an HTTP health check
  Consul polls every 10s.
- **Consul** — runs in `-dev` mode (single in-memory agent, no clustering).
  Acts as the service catalog and exposes both an HTTP API (8500) and a DNS
  interface (8600) for discovery.
- **Gateway** — the single entry point (port 8080). Routes
  `GET /:service/*` requests by looking up `<service>.service.consul` via
  Consul's DNS interface, then proxies the request to whichever healthy
  instance it resolves.

All containers run on one Docker network (`consul-net`) via Docker Compose,
deployed on a single EC2 Ubuntu instance.

## Running it

```bash
docker compose up --build -d
docker compose ps          # confirm all 5 containers are up
curl localhost:8080/service-a/info
curl localhost:8080/service-b/info
curl localhost:8080/service-c/info
```

Consul's web UI is available at `http://<host>:8500` — useful for visually
confirming registration and health check status.

**Required inbound ports** (EC2 security group): 8080 (gateway), 8500
(Consul UI/API), 8600 TCP+UDP (Consul DNS).

## Service discovery: two methods implemented

The gateway resolves services via Consul's **DNS interface**, with a
fallback path for resilience:

1. **Primary — Node's built-in DNS resolver** (`dns.promises.Resolver`),
   pointed at Consul's DNS port. Queries `A` and `SRV` records for
   `<service>.service.consul` in parallel to get an IP and port.
2. **Fallback — raw UDP DNS queries**, built directly with the
   `dns-packet` library over a raw `dgram` socket. Bypasses Node's resolver
   entirely and talks to Consul's DNS server directly. Triggers
   automatically if the primary resolver throws.

Both paths were verified independently by deliberately breaking the primary
resolver's target port and confirming the gateway still resolved services
correctly and logged the fallback trigger.

## Verifying health checks / failover

```bash
docker compose stop service-a
sleep 15   # allow the 10s health check interval to catch it
curl localhost:8080/service-a/info                              # 503 / discovery error
curl "localhost:8500/v1/health/service/service-a?passing=true"  # []
docker compose start service-a
curl localhost:8080/service-a/info                               # back to normal
```

This confirms Consul removes unhealthy instances from DNS answers, and the
gateway correctly fails instead of routing to a dead service.

## Link

[roadmap.sh](https://roadmap.sh/projects/service-discovery)
