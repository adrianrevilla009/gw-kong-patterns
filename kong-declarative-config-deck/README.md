# kong-declarative-config-deck

A base Kong config and a production overlay in `config/`, merged and validated by decK, then loaded into DB-less Kong 3.7.1.

## Goal

Manage Kong config as files: compose environment overlays with decK, validate them offline, and load the result into Kong.

## Run it

```bash
./verify.sh
```

Expected: the response status line and `X-RateLimit-Limit-Minute: 100` from `curl localhost:8000/orders`, then `OK`. The script runs decK v1.40.3 in Docker for the merge and validate steps and removes the compose stack on exit.

Not run end to end: the decK and Kong images were not available when this was written, so the output above is what the script should print and the decK tag has not been checked.

## What it proves

- `deck file merge config/base.yaml config/overlay-prod.yaml -o kong.yml` combines the `orders` service and route with the overlay's `rate-limiting` plugin; `kong.yml` is generated and git-ignored.
- `deck file validate kong.yml` checks the result without a running Kong, so it fits a validate-only CI job.
- Kong boots from that file and the plugin is live (`minute: 100`).

## Trade-offs

- DB-less Kong cannot be updated with `deck gateway sync`; with a database or Konnect you would diff and sync instead of mounting a file.
- Overlays merge by entity name, so a typo creates a new entity instead of failing.
- Only one overlay (`prod`) exists; adding environments means more files and a script change.

## When not to use it

- When a Kubernetes controller (Kong Ingress Controller) owns the config.
- For a throwaway environment edited by hand through the Admin API.
