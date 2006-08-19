# ${ROOT} must be mounted during sysinit startup
ROOT = /

install: src/readahead-fs
	install -d /var/cache/bootcache
	install -m 755 -s src/readahead-fs ${ROOT}/sbin/readahead-fs
	install -m 755 scripts/bootcache ${ROOT}/sbin/bootcache
	install -m 755 scripts/filecache ${ROOT}/usr/sbin/filecache
	install -m 755 scripts/bootcache.sh ${ROOT}/etc/init.d/bootcache.sh
	install -m 644 etc/default/bootcache ${ROOT}/etc/default/bootcache
	update-rc.d bootcache.sh start 3 S . start 99 2 3 4 5 . start 25 0 6 .

uninstall:
	rm -fr /var/cache/bootcache
	rm -f ${ROOT}/sbin/readahead-fs
	rm -f ${ROOT}/sbin/bootcache
	rm -f ${ROOT}/usr/sbin/filecache
	rm -f ${ROOT}/etc/init.d/bootcache.sh
	rm -f ${ROOT}/etc/default/bootcache
	update-rc.d bootcache.sh remove

src/readahead-fs:
	cd src; make
