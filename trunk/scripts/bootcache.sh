#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache
# Required-Start:    mountkernfs sendsigs
# Required-Stop:
# Default-Start:     S 2 3 4 5  0 6
# Default-Stop:
# Short-Description: preload boot files on startup;
#                    do scheduled defrag on reboot/shutdown;
#                    log the sysv-init/desktop boot time
### END INIT INFO

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

PATH=/sbin:/bin

function wait_for_process_start()
{
    until pidof $1 > /dev/null; do sleep 1; done
}

function wait_for_process_stop()
{
    while pidof $1 > /dev/null; do sleep 1; done
}

function wait_for_process()
{
	SIGNAL_PROGRAM=$1
	while shift
	do
		if   [ "$1" = 'start' ]; then wait_for_process_start $SIGNAL_PROGRAM
		elif [ "$1" = 'stop'  ]; then wait_for_process_stop  $SIGNAL_PROGRAM
		else break; fi
	done
}

function memory_above_any()
{
	while true
	do
		sleep 1
		{
			read MemTotal total_kb unit;
			read MemFree   free_kb unit;
		} < /proc/meminfo
		let 'used_kb = total_kb - free_kb'

		for size in $*
		do
			if   [ $size != ${size%%%} ]; then
				percent=${size%%%}
				let 'min_kb = percent * total_kb / 100'
			elif [ $size != ${size%%M} ]; then
				megabyte=${size%%M}
				let 'min_kb = megabyte * 1024'
			fi

			[ $used_kb -gt $min_kb ] && return
		done
	done
}

function log_line()
{
	echo $@ >> $CACHE_ROOT/uptime
}

function log_boot_time()
{
	[ -z "$BOOTTIME_LOG_WAITCMD" ] && return

	# sysv-init boot time
	log_line "SYSV $(</proc/uptime) $PRELOAD_TASK \#  `date` `uname -a`"

	(
		# do the wait
		eval $BOOTTIME_LOG_WAITCMD

		# GUI desktop ready time
		log_line "GUI  $(</proc/uptime) $PRELOAD_TASK"
		log_line
	)&
}

function auto_filecache_snapshot()
{
	[ -z "$CACHE_SNAPSHOT_WAITCMD" ] && return

	(
		# do the wait
		eval $CACHE_SNAPSHOT_WAITCMD

		# take a snapshot of /proc/filecache
		bootcache stop boot
	)&
}
	
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
			[ "$PRELOAD_TASK" ] && bootcache preload $PRELOAD_TASK
		else
			log_boot_time
			auto_filecache_snapshot
		fi
		;;
	stop)
		if [ "$RUNLEVEL" = "0" -o "$RUNLEVEL" = "6" ]; then
			check_do_defrag
		fi
		;;
	*)
		echo "Usage: $0 start|stop" >&2
		exit 3
		;;
esac

:
