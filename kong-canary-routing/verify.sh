#!/usr/bin/env bash
# 200 requests through a 90/10 weighted upstream; the canary share must be roughly 10%.
set -euo pipefail
cd "$(dirname "$0")"
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose up -d --wait >/dev/null
v2=0
for _ in $(seq 200); do
  curl -s localhost:8000/orders | grep -q '^Name: v2' && v2=$((v2 + 1)) || true
done
echo "canary (v2) hits: $v2/200 (expected ~20)"
[ "$v2" -gt 3 ] && [ "$v2" -lt 60 ] || { echo "FAIL"; exit 1; }
hdr=$(curl -s -H 'X-Canary: true' localhost:8000/orders | grep '^Name:')
echo "with X-Canary: true -> $hdr"
[ "$hdr" = "Name: v2" ]
echo "OK"
