#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache
# Required-Start:    mountkernfs
# Required-Stop:
# Default-Start:     S
# Default-Stop:      0 6
# Short-Description: preload boot files on startup;
#                    do scheduled defrag on reboot/shutdown.
### END INIT INFO

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

function check_do_defrag()
{
	tasks=`cd $CACHE_ROOT; echo *`
	for task in $tasks
	do
		dfrag_root="$CACHE_ROOT/$task/defrag"
		if [ -d $defrag_root ]; then
			bootcache defrag-now $task
		fi
	done
}

case "$1" in
	start)
		if [ "$RUNLEVEL" = "S" -a "$PREVLEVEL" = "N" ]; then
			bootcache preload boot
		fi
		;;
	stop)
		if [ "$RUNLEVEL" = "0" -o "$RUNLEVEL" = "6" ]; then
			check_do_defrag
		fi
		;;
esac
