# kong-jwt-oidc-auth

Keycloak 25 (dev mode, imported realm `orders`) in front of Kong's `jwt` plugin, with a script that fetches the realm key and tests three requests.

## Goal

Protect a route so only a valid Keycloak-issued JWT gets through Kong.

## Run it

```bash
./verify.sh
```

Expected: `no token: 401, tampered token: 401, valid token: 200`, then `OK`. It needs Docker, `python3` and `curl`, and waits for Keycloak for up to about three minutes.

Not run end to end: the Keycloak and Kong images were not available when this was written, so the output above is what the script should print, not a captured run.

## What it proves

- `realm-orders.json` gives Keycloak a realm `orders` with the public client `orders-cli` and the user `alice` (password `demo-only-pw`), so a token comes from the password grant.
- `render_key.py` turns the RS256 key from the realm's JWKS endpoint into a PEM public key; `verify.sh` writes it into `kong.generated.yml` from `kong.template.yml`.
- The `jwt` plugin matches the token's `iss` claim to the consumer key `http://localhost:8080/realms/orders`, which is why compose sets `KC_HOSTNAME_URL`.
- OIDC discovery in Kong (`openid-connect` plugin) is Enterprise-only, so OSS Kong validates the signature against a copied key.

## Trade-offs

- The key is copied once; Keycloak key rotation breaks validation until the config is rendered again.
- The `jwt` plugin here verifies signature and `exp`, not audience or scopes.
- Dev-mode Keycloak with a demo password is for the lab only.

## When not to use it

- When keys rotate often; use a plugin or sidecar that fetches JWKS dynamically.
- When you need audience or scope checks or token introspection at the gateway.
