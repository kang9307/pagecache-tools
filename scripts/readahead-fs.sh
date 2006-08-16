#!/bin/sh

PATH=.:$PATH

[ $# -lt 1 ] && exit 1

dev=`basename $1`

while true
do                                                                                                  
    grep -q $dev /etc/mtab    && break
    grep -q $dev /proc/mounts && break
    sleep 1
done

readahead-fs $1

exit 0

# vim: ts=4 sw=4
