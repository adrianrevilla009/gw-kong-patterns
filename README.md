# gw-kong-patterns

Six small Kong gateway setups (DB-less, declarative config) that each show one pattern with request and response evidence, using a shared Orders example.

## What is inside

| Folder | What it shows | Run |
| --- | --- | --- |
| [`kong-rate-limit`](./kong-rate-limit) | `rate-limiting` plugin returning a real `429` after 3 requests per minute | `./verify.sh` |
| [`kong-jwt-oidc-auth`](./kong-jwt-oidc-auth) | `jwt` plugin accepting a Keycloak-issued RS256 token and rejecting missing or tampered ones | `./verify.sh` |
| [`kong-lua-plugin`](./kong-lua-plugin) | A custom Lua plugin (`order-stamp`) loaded into Kong, stamping a header on request and response | `./verify.sh` |
| [`kong-request-transform`](./kong-request-transform) | `request-transformer` and `response-transformer` rewriting headers and URI | `./verify.sh` |
| [`kong-canary-routing`](./kong-canary-routing) | 90/10 weighted upstream plus a header-forced canary route | `./verify.sh` |
| [`kong-declarative-config-deck`](./kong-declarative-config-deck) | decK merging a base file and an overlay, validating it, and loading it into Kong | `./verify.sh` |

## Prerequisites

- Docker with the Compose plugin (images: Kong 3.7.1, traefik/whoami v1.10.2, Keycloak 25.0.2, decK v1.40.3)
- `curl` and a POSIX shell with bash
- Python 3 (only for `kong-jwt-oidc-auth`)

Everything runs locally and each script removes its containers on exit, so there is no cost.

## How to read it

Start with `kong-rate-limit`: it is the smallest folder and shows the compose-plus-`kong.yml` layout the others reuse. Then read `kong-jwt-oidc-auth` for the most involved wiring.

None of the `verify.sh` scripts has been run end to end yet: the Kong, Keycloak and decK images were not available where these folders were written. The config files parse, but the expected outputs in each folder README come from reading the config, not from a captured run.
