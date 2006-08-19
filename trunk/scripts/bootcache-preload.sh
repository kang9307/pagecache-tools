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
		if [ "$PRELOAD_TASK" -a -d "$CACHE_ROOT/$PRELOAD_TASK/preload" ]
			bootcache preload $PRELOAD_TASK
		fi
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
