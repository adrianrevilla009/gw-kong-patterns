#!/usr/bin/env bash
# decK merges base + overlay into kong.yml, validates it offline, then Kong boots from it.
set -euo pipefail
cd "$(dirname "$0")"
DECK="docker run --rm -v $PWD:/work -w /work kong/deck:v1.40.3"
trap 'docker compose down -v >/dev/null 2>&1' EXIT
$DECK file merge config/base.yaml config/overlay-prod.yaml -o kong.yml
$DECK file validate kong.yml
grep -q 'rate-limiting' kong.yml
docker compose up -d --wait >/dev/null
curl -si localhost:8000/orders | grep -iE '^(HTTP|x-ratelimit-limit-minute)'
echo "OK"
