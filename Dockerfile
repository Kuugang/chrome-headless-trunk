FROM alpeware/chrome-headless-trunk

RUN apt-get update && apt-get install -y --no-install-recommends nginx curl \
  && rm -rf /var/lib/apt/lists/*

# Template (will be rendered with envsubst)
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# IMPORTANT: expose ONLY the proxy port (not 9222)
EXPOSE 8080

# Healthcheck goes via nginx (public side), not Chrome
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${PORT:-8080}/json/version" >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

