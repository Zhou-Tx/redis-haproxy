#!/bin/sh
set -e

if [ -n "$1" ]; then
    exec "$@"
fi
if [ -z "$REDIS_SERVERS" ]; then
    echo "ERROR: expected REDIS_SERVERS" 1>&2
    exit 1
fi
if [ -z "$HOST" ]; then
    HOST='0.0.0.0'
fi
if [ -z "$PORT" ]; then
    PORT='6379'
fi
if [ -z "$CHECK_TIMEOUT" ]; then
    CHECK_TIMEOUT='3s'
fi
if [ -z "$CONNECT_TIMEOUT" ]; then
    CONNECT_TIMEOUT='10s'
fi

echo 'listen master'                                                 > /var/lib/haproxy/haproxy.cfg
echo '    mode tcp'                                                 >> /var/lib/haproxy/haproxy.cfg
echo "    bind $HOST:$PORT"                                         >> /var/lib/haproxy/haproxy.cfg
echo '    maxconn 20000'                                            >> /var/lib/haproxy/haproxy.cfg
echo "    timeout check   $CHECK_TIMEOUT"                           >> /var/lib/haproxy/haproxy.cfg
echo "    timeout connect $CONNECT_TIMEOUT"                         >> /var/lib/haproxy/haproxy.cfg
echo "    timeout server  $CONNECT_TIMEOUT"                         >> /var/lib/haproxy/haproxy.cfg
echo "    timeout client  $CONNECT_TIMEOUT"                         >> /var/lib/haproxy/haproxy.cfg
echo ''                                                             >> /var/lib/haproxy/haproxy.cfg
echo '    retries 3'                                                >> /var/lib/haproxy/haproxy.cfg
echo '    option redispatch'                                        >> /var/lib/haproxy/haproxy.cfg
echo '    option tcp-check'                                         >> /var/lib/haproxy/haproxy.cfg
if [ -n "$REDIS_PASSWORD" ]; then
echo "    tcp-check send auth\ $REDIS_USER\ $REDIS_PASSWORD"'\\r\\n'>> /var/lib/haproxy/haproxy.cfg
echo "    tcp-check expect string +OK"                              >> /var/lib/haproxy/haproxy.cfg
fi
echo '    tcp-check send PING''\\r\\n'                              >> /var/lib/haproxy/haproxy.cfg
echo '    tcp-check expect string +PONG'                            >> /var/lib/haproxy/haproxy.cfg
echo '    tcp-check send INFO\ REPLICATION''\\r\\n'                 >> /var/lib/haproxy/haproxy.cfg
echo '    tcp-check expect string role:master'                      >> /var/lib/haproxy/haproxy.cfg
echo '    tcp-check send QUIT''\\r\\n'                              >> /var/lib/haproxy/haproxy.cfg
echo '    tcp-check expect string +OK'                              >> /var/lib/haproxy/haproxy.cfg
echo -n $REDIS_SERVERS | sed 's/,/\n/g' | xargs -i \
echo "    server {} {} check inter 1s"                              >> /var/lib/haproxy/haproxy.cfg

exec haproxy -W -db -f /var/lib/haproxy/haproxy.cfg
