# kong-rate-limit

Kong 3.7.1 in DB-less mode with the `rate-limiting` plugin on one service, plus a `verify.sh` that sends five requests.

## Goal

Throttle a route with Kong's `rate-limiting` plugin and see a real `429` once the quota is used up.

## Run it

```bash
./verify.sh
```

Expected: `status codes: 200 200 200 429 429`, then the response line and `RateLimit-Remaining` / `Retry-After` headers of a sixth request, then `OK`. The script starts Kong and a whoami upstream with `docker compose` and removes them on exit.

Not run end to end: the Kong image was not available when this was written, so the output above is what the config and script should produce, not a captured run.

## What it proves

- `kong.yml` attaches the `rate-limiting` plugin to the `orders` service declaratively, with `minute: 3` and `limit_by: ip`.
- Requests 1-3 should return `200` and requests 4-5 `429`; `verify.sh` fails if the sequence differs.
- With `hide_client_headers: false` the rate-limit headers are visible to the client, so a caller can see its remaining quota.

## Trade-offs

- `policy: local` counts per Kong node: exact on one node, approximate behind several. Use the `redis` policy for a shared counter.
- `limit_by: ip` penalises many clients behind one NAT; `consumer` or `header` is fairer.
- The fixed one-minute window allows a burst at each window boundary.

## When not to use it

- When you need per-tenant quotas with billing semantics or burst smoothing (token bucket); use a dedicated quota service.
- When the limit must be exact across a fleet without adding Redis.
