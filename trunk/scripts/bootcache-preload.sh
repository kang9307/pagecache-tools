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

.  /etc/default/bootcache

case "$1" in
	start)
		[ "$PRELOAD_TASK" ] && bootcache preload $PRELOAD_TASK
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
