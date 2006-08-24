# ${ROOT} must be mounted during sysinit startup
ROOT = /

install: src/readahead-fs
	install -d /var/cache/bootcache
	install -m 755 -s src/readahead-fs		${ROOT}/sbin/
	install -m 755 scripts/bootcache		${ROOT}/sbin/
	install -m 755 scripts/filecache		${ROOT}/usr/sbin/

uninstall:
	rm -fr /var/cache/bootcache
	rm -f ${ROOT}/sbin/readahead-fs
	rm -f ${ROOT}/sbin/bootcache
	rm -f ${ROOT}/usr/sbin/filecache

src/readahead-fs:
	cd src; make
