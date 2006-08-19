#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache-timing
# Required-Start:    rmnologin
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: run bootcache tasks when boot completed
# Description:
#              - take /proc/filecache snapshot;
#              - log the sysv-init/desktop boot time
### END INIT INFO

PATH=/sbin:/bin

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

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

function take_filecache_snapshot()
{
	[ -z "$CACHE_SNAPSHOT_WAITCMD" ] && return

	(
		# do the wait
		eval $CACHE_SNAPSHOT_WAITCMD

		# take a snapshot of /proc/filecache
		bootcache stop boot
	)&
}

case "$1" in
	start)
		log_boot_time
		take_filecache_snapshot
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
