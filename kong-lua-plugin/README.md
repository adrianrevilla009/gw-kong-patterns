# kong-lua-plugin

A custom Kong plugin, `order-stamp` (`plugins/order-stamp/handler.lua` and `schema.lua`), mounted into Kong 3.7.1 and enabled on one route.

## Goal

Write and load a minimal custom plugin in Lua using Kong's Plugin Development Kit (PDK).

## Run it

```bash
./verify.sh
```

Expected: two lines `X-Order-Stamp: stamped-by-lua` (one in the response headers, one in whoami's echo of the request), then `OK`. It starts Kong and a whoami upstream with `docker compose` and removes them on exit.

Not run end to end: the Kong image was not available when this was written, so the plugin has never been loaded and the output above is what the script should print.

## What it proves

- `schema.lua` declares the config: `message` is required and `header_name` defaults to `X-Order-Stamp`; Kong validates it when it loads `kong.yml`.
- `handler.lua` uses two phases: `access` sets the header on the upstream request, `header_filter` sets it on the client response.
- `docker-compose.yml` loads the plugin with `KONG_PLUGINS: bundled,order-stamp` and a read-only volume mount.

## Trade-offs

- Lua plugins run in the proxy's hot path; a bug or blocking call affects every route.
- The mount is fine for a lab; real deployments bake plugins into the image.
- The plugin has no tests of its own; `verify.sh` is the only check.

## When not to use it

- When a bundled plugin already does the job.
- For business-specific logic; keep it in a service. Go and JavaScript plugin servers exist but add an inter-process hop.
