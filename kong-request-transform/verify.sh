#!/usr/bin/env bash
# whoami echoes what the upstream received, so we can assert on the rewritten request.
set -euo pipefail
cd "$(dirname "$0")"
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose up -d --wait >/dev/null
out=$(curl -si -H 'X-Secret: leak' localhost:8000/v1/orders)
echo "$out" | grep -iE '^(X-Served-By|GET |X-Gateway|X-Tenant|X-Secret)'
echo "$out" | grep -qi '^X-Served-By: kong'
echo "$out" | grep -q 'GET /api/orders'
echo "$out" | grep -qi '^X-Gateway: kong'
! echo "$out" | grep -qi '^X-Secret'
echo "OK"
