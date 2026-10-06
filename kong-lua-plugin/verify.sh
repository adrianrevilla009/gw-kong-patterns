#!/usr/bin/env bash
# The custom plugin must show up in the response and in the upstream's echo of the request.
set -euo pipefail
cd "$(dirname "$0")"
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose up -d --wait >/dev/null
out=$(curl -si localhost:8000/orders)
echo "$out" | grep -i 'x-order-stamp'
[ "$(echo "$out" | grep -ci '^x-order-stamp: stamped-by-lua')" -eq 2 ]  # response header + upstream echo
echo "OK"
