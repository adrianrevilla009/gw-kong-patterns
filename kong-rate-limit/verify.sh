#!/usr/bin/env bash
# Sends 5 requests against a 3/minute limit; expects 200,200,200,429,429.
set -euo pipefail
cd "$(dirname "$0")"
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose up -d --wait >/dev/null
codes=$(for _ in 1 2 3 4 5; do curl -s -o /dev/null -w '%{http_code} ' localhost:8000/orders; done)
echo "status codes: $codes"
[ "$codes" = "200 200 200 429 429 " ] || { echo "FAIL"; exit 1; }
curl -si localhost:8000/orders | grep -iE '^(HTTP|ratelimit-remaining|retry-after)'
echo "OK"
