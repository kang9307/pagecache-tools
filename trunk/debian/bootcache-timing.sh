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

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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
	echo "$@" >> $CACHE_ROOT/uptime
}

function log_boot_time()
{
	[ -z "$UPTIME_LOG_TIMING" ] && return

	log_line "PRELOAD_TASK=$PRELOAD_TASK DATE=`date` KERNEL=`uname -a`"

	# sysv-init boot time
	log_line "SYSV $(</proc/uptime)"

	(
		# do the wait
		eval $UPTIME_LOG_TIMING

		# GUI desktop ready time
		log_line "GUI  $(</proc/uptime)"
	)&
}

function log_bootchart()
{
	local task_root="$CACHE_ROOT/$PRELOAD_TASK"
	[ -e $task_root/bootchart3.png ] && rm -fr $task_root/bootchart3.png
	[ -e $task_root/bootchart2.png ] && mv $task_root/bootchart2.png $task_root/bootchart3.png
	[ -e $task_root/bootchart1.png ] && mv $task_root/bootchart1.png $task_root/bootchart2.png
	[ -e $task_root/bootchart.png ]  && mv $task_root/bootchart.png  $task_root/bootchart1.png
	bootchart -o $task_root
}

function take_filecache_snapshot()
{
	[ -z "$CACHE_SNAPSHOT_TIMING" ] && return

	(
		# do the wait
		eval $CACHE_SNAPSHOT_TIMING

		# take a snapshot of /proc/filecache
		bootcache stop boot

		# debug the boot progress
		[ "$VERBOSE" -ge 10 ] && log_bootchart
	)&
}

case "$1" in
	start)
		log_boot_time
		take_filecache_snapshot
		;;
	stop|'')
		# No-op
		;;
	*)
		echo "Usage: $0 [start|stop]" >&2
		exit 3
		;;
esac

:
