# ${ROOT} must be mounted during sysinit startup
ROOT = /

install:
	install -m 755 bootcache-preload.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-timing.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-defrag.sh	${ROOT}/etc/init.d/
	install -m 644 etc/default/bootcache	${ROOT}/etc/default/
	update-rc.d bootcache-preload.sh start 3 S .
	update-rc.d bootcache-timing.sh	 start 99 2 3 4 5 .
	update-rc.d bootcache-defrag.sh  start 25 0 6 .

uninstall:
	rm -f ${ROOT}/etc/init.d/bootcache-preload.sh
	rm -f ${ROOT}/etc/init.d/bootcache-timing.sh
	rm -f ${ROOT}/etc/init.d/bootcache-defrag.sh
	rm -f ${ROOT}/etc/default/bootcache
	update-rc.d bootcache-preload.sh remove
	update-rc.d bootcache-timing.sh  remove
	update-rc.d bootcache-defrag.sh  remove
