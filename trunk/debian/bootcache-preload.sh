#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache-preload
# Required-Start:    mountkernfs
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: boot time speedup through precaching
### END INIT INFO

PATH=/sbin:/bin

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

case "$1" in
	start)
		[ -n "$PRELOAD_TASK" ] || exit 0
		[ -d "$CACHE_ROOT/$PRELOAD_TASK/preload" ] || exit 0
		grep -Eq '\<(nopreload|single|1)\>' /proc/cmdline && exit 0

		bootcache preload $PRELOAD_TASK &
		;;
	stop)
		# No-op
		;;
	*)
		echo "Usage: $0 start" >&2
		exit 3
		;;
esac

:
