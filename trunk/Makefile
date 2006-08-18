# ${ROOT} must be mounted during sysinit startup
ROOT = /

install: src/readahead-fs
	install -m 755 -s src/readahead-fs ${ROOT}/sbin/readahead-fs
	install -m 755 scripts/bootcache ${ROOT}/sbin/bootcache
	install -m 755 scripts/filecache ${ROOT}/usr/sbin/filecache
	install -m 755 scripts/bootcache.sh ${ROOT}/etc/init.d/bootcache.sh
	install -m 644 etc/default/bootcache ${ROOT}/etc/default/bootcache

uninstall:
	rm -f ${ROOT}/sbin/readahead-fs
	rm -f ${ROOT}/sbin/bootcache
	rm -f ${ROOT}/usr/sbin/filecache
	rm -f ${ROOT}/etc/init.d/bootcache.sh
	rm -f ${ROOT}/etc/default/bootcache

src/readahead-fs:
	cd src; make
