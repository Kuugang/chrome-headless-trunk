#!/bin/sh
set -e

PORT="${PORT:-8080}"
CDP_PORT="${CDP_PORT:-9222}"

# 1) Start Chrome PRIVATE on 127.0.0.1
CHROME_ARGS="--headless --disable-gpu --no-sandbox \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port=${CDP_PORT} \
  --user-data-dir=/data \
  --disable-dev-shm-usage"

[ -n "${CHROME_OPTS}" ] && CHROME_ARGS="$CHROME_ARGS $CHROME_OPTS"

echo "[entrypoint] starting Chrome on 127.0.0.1:${CDP_PORT} ..."
/usr/bin/google-chrome-unstable $CHROME_ARGS >/var/log/chrome.log 2>&1 &

# 2) Wait for Chrome CDP
for i in $(seq 1 80); do
  if curl -fsS "http://127.0.0.1:${CDP_PORT}/json/version" >/dev/null 2>&1; then
    echo "[entrypoint] Chrome DevTools is up."
    break
  fi
  sleep 0.25
done

# 3) Render nginx config with actual $PORT
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "[entrypoint] starting nginx on :${PORT} ..."
exec nginx -g 'daemon off;'

