FROM alpeware/chrome-headless-trunk

VOLUME ["/data"]
EXPOSE 9222

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 CMD wget -qO- http://127.0.0.1:9222/json/version >/dev/null || exit 1

ENTRYPOINT ["/usr/bin/google-chrome-unstable"]
CMD ["--headless","--disable-gpu","--no-sandbox","--remote-debugging-address=0.0.0.0","--remote-debugging-port=9222","--remote-allow-origins=*","--user-data-dir=/data"]
