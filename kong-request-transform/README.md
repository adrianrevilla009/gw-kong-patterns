# kong-request-transform

Kong 3.7.1 with `request-transformer` and `response-transformer` on one service, in front of a whoami echo upstream.

## Goal

Rewrite the request on its way upstream and the response on its way back, without touching the service.

## Run it

```bash
./verify.sh
```

Expected: a filtered view of the response with `X-Served-By: kong`, `GET /api/orders`, `X-Gateway: kong` and `X-Tenant: acme`, no `X-Secret` line, then `OK`. The script sends `X-Secret: leak` to `/v1/orders`.

Not run end to end: the Kong image was not available when this was written, so the output above is what the script should print, not a captured run.

## What it proves

- In `kong.yml`, `request-transformer` adds `X-Gateway` and `X-Tenant`, removes `X-Secret` and replaces the upstream URI with `/api/orders`.
- `response-transformer` adds `X-Served-By: kong` to the client response.
- whoami echoes what it received, so `verify.sh` can assert on the upstream's view of the request.

## Trade-offs

- Transformations are invisible to service owners; document them next to the service.
- Plugin order matters when several plugins touch the same header.
- `replace.uri` is a fixed path, so every request to `/v1/orders` reaches the same upstream path.

## When not to use it

- For body reshaping or business logic; put that in a service or a backend-for-frontend.
- As a substitute for authentication; stripping a header does not secure anything.
