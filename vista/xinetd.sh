#!/bin/sh
docker exec -it -u 0 iris /usr/sbin/xinetd -pidfile /run/xinetd.pid -stayalive -inetd_compat