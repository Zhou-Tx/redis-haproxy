FROM haproxy:lts

COPY docker-entrypoint.sh /bin/

ENV PORT 6379
ENTRYPOINT ["/bin/docker-entrypoint.sh"]
HEALTHCHECK --interval=10s --timeout=2s CMD bash -c "echo > \"/dev/tcp/127.0.0.1/$PORT\" || exit 1"
