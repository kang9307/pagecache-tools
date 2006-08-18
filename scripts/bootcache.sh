#!/bin/sh
### BEGIN INIT INFO
# Provides:          bootcache
# Required-Start:    mountkernfs
# Required-Stop:
# Default-Start:     S 2 3 4 5
# Default-Stop:      0 6
# Short-Description: preload boot files on startup;
#                    do scheduled defrag on reboot/shutdown;
#                    log the sysv-init/desktop boot time
### END INIT INFO

CACHE_ROOT=/var/cache/bootcache
.  /etc/default/bootcache

PATH=/sbin:/bin
grep -q bootcache /proc/cmdline && BOOTCACHE=bootcache

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

function log_line()
{
	echo $@ >> $CACHE_ROOT/uptime
}

function log_boot_time()
{
	if [ -z "$BOOTTIME_LOG_WAITCMD" ]; then
		return
	fi

	# sysv-init boot time
	log_line "SYSV $(</proc/uptime) $BOOTCACHE \#  `date` `uname -a`"

	(
		# do the wait
		eval $BOOTTIME_LOG_WAITCMD

		# GUI desktop ready time
		log_line "GUI  $(</proc/uptime) $BOOTCACHE"
		log_line
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
			bootcache preload boot
		else
			log_boot_time
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
