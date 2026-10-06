#!/usr/bin/env bash
# Keycloak issues a token; Kong's jwt plugin (public key pulled from Keycloak's JWKS) accepts or rejects it.
set -euo pipefail
cd "$(dirname "$0")"
REALM=http://localhost:8080/realms/orders
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose up -d keycloak orders >/dev/null
for _ in $(seq 60); do curl -sf "$REALM" >/dev/null && break || sleep 3; done
curl -sf "$REALM/protocol/openid-connect/certs" | python3 render_key.py > key.pem.txt
python3 - <<'PY'
key = open("key.pem.txt").read().rstrip("\n")
open("kong.generated.yml", "w").write(open("kong.template.yml").read().replace("__PUBKEY__", key))
PY
rm -f key.pem.txt
docker compose up -d --wait kong >/dev/null
no_token=$(curl -s -o /dev/null -w '%{http_code}' localhost:8000/orders)
token=$(curl -sf -d grant_type=password -d client_id=orders-cli -d username=alice -d password=demo-only-pw \
  "$REALM/protocol/openid-connect/token" | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
bad=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer ${token}x" localhost:8000/orders)
good=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" localhost:8000/orders)
echo "no token: $no_token, tampered token: $bad, valid token: $good"
[ "$no_token" = 401 ] && [ "$bad" = 401 ] && [ "$good" = 200 ] || { echo "FAIL"; exit 1; }
echo "OK"
