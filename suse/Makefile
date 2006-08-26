# ${ROOT} must be mounted during sysinit startup
ROOT = /

install:
	install -m 755 bootcache-preload.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-timing.sh	${ROOT}/etc/init.d/
	install -m 755 bootcache-defrag.sh	${ROOT}/etc/init.d/
	install -m 644 etc/default/bootcache	${ROOT}/etc/default/

uninstall:
	insserv -r bootcache-preload.sh
	insserv -r bootcache-timing.sh
	insserv -r bootcache-defrag.sh
	rm -f ${ROOT}/etc/init.d/bootcache-preload.sh
	rm -f ${ROOT}/etc/init.d/bootcache-timing.sh
	rm -f ${ROOT}/etc/init.d/bootcache-defrag.sh
	rm -f ${ROOT}/etc/default/bootcache

enable-bootcache:
	chmod +x /sbin/bootcache
	insserv bootcache-preload.sh
	insserv bootcache-timing.sh

disable-bootcache:
	chmod -x /sbin/bootcache
	insserv -r bootcache-preload.sh
	insserv -r bootcache-timing.sh

disable-preload:
	chmod -x /usr/sbin/bootcache
	chmod -x /sbin/preload
	insserv -r boot.preload
	insserv -r boot.preload_early

enable-preload:
	chmod +x /usr/sbin/bootcache
	chmod +x /sbin/preload
	insserv boot.preload_early
	insserv boot.preload
