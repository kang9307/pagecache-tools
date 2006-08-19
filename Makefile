# ${ROOT} must be mounted during sysinit startup
ROOT = /

install: src/readahead-fs
	install -d /var/cache/bootcache
	install -m 755 -s src/readahead-fs		${ROOT}/sbin/
	install -m 755 scripts/bootcache		${ROOT}/sbin/
	install -m 755 scripts/filecache		${ROOT}/usr/sbin/
	install -m 755 scripts/bootcache.sh		${ROOT}/etc/init.d/
	install -m 755 scripts/bootcache-defrag.sh	${ROOT}/etc/init.d/
	install -m 644 etc/default/bootcache		${ROOT}/etc/default/
	update-rc.d bootcache-preload.sh start 3 S .
	update-rc.d bootcache-timing.sh	 start 99 2 3 4 5 .
	update-rc.d bootcache-defrag.sh  start 25 0 6 .

uninstall:
	rm -fr /var/cache/bootcache
	rm -f ${ROOT}/sbin/readahead-fs
	rm -f ${ROOT}/sbin/bootcache
	rm -f ${ROOT}/usr/sbin/filecache
	rm -f ${ROOT}/etc/init.d/bootcache.sh
	rm -f ${ROOT}/etc/init.d/bootcache-defrag.sh
	rm -f ${ROOT}/etc/default/bootcache
	update-rc.d bootcache-preload.sh remove
	update-rc.d bootcache-timing.sh  remove
	update-rc.d bootcache-defrag.sh  remove

src/readahead-fs:
	cd src; make
