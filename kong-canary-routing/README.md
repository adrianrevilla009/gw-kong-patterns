# kong-canary-routing

Kong 3.7.1 with a 90/10 weighted upstream over two whoami "versions" and a second route that forces the canary by header.

## Goal

Send a small share of traffic to a new version and let testers force it with a header.

## Run it

```bash
./verify.sh
```

Expected: `canary (v2) hits: N/200 (expected ~20)` with N between 4 and 59, then `with X-Canary: true -> Name: v2` and `OK`. The script starts Kong and both upstreams with `docker compose` and removes them on exit.

Not run end to end: the Kong image was not available when this was written, so the output above is what the script should print, not a captured run.

## What it proves

- The upstream `orders-weighted` in `kong.yml` has targets `orders-v1:80` (weight 90) and `orders-v2:80` (weight 10); 200 requests should give roughly 20 `Name: v2` echoes.
- A second route, `orders-canary-header`, matches `/orders` plus `x-canary: true` and points straight at `orders-v2`, so that request always lands on `v2`.
- The `canary` plugin is Enterprise-only, so this uses weighted upstream targets.

## Trade-offs

- Weights are per Kong node and not sticky: one user can bounce between versions.
- There is no automatic rollback or metric analysis; changing weights means changing the config.
- The check is statistical; the accepted range (4-59 of 200) is wide on purpose.

## When not to use it

- When you need sticky cohorts, promotion on error rates, or traffic mirroring; use a mesh or a progressive-delivery tool such as Argo Rollouts or Flagger.
