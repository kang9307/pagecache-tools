#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache-defrag
# Required-Start:    sendsigs
# Required-Stop:
# Default-Start:     0 6
# Default-Stop:
# Short-Description: run scheduled defrag on reboot/shutdown time
### END INIT INFO

PATH=/sbin:/bin

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

function check_do_defrag()
{
	# cannot handle task name with whitespace here
	tasks=`cd $CACHE_ROOT && echo *`
	for task in $tasks
	do
		defrag_root="$CACHE_ROOT/$task/defrag"
		if [ -d "$defrag_root" ]; then
			bootcache defrag-now "$task"
		fi
	done
}

case "$1" in
	start)
		# no op
		;;
	stop)
		check_do_defrag
		;;
	*)
		echo "Usage: $0 stop" >&2
		exit 3
		;;
esac

:
