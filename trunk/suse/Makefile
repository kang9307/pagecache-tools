# ${ROOT} must be mounted during sysinit startup
ROOT = /

install:
	install -m 755 bootcache-preload.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-timing.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-defrag.sh	${ROOT}/etc/init.d/
	install -m 644 etc/default/bootcache	${ROOT}/etc/default/
	insserv bootcache-preload.sh
	insserv bootcache-timing.sh
	#insserv bootcache-defrag.sh

uninstall:
	insserv -r bootcache-preload.sh
	insserv -r bootcache-timing.sh
	#insserv -r bootcache-defrag.sh
	rm -f ${ROOT}/etc/init.d/bootcache-preload.sh
	rm -f ${ROOT}/etc/init.d/bootcache-timing.sh
	rm -f ${ROOT}/etc/init.d/bootcache-defrag.sh
	rm -f ${ROOT}/etc/default/bootcache
