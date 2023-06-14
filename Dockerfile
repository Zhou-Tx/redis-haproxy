FROM haproxy:lts-alpine

COPY docker-entrypoint.sh /bin/

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
