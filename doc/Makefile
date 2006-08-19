MANPAGES = bootcache.8 filecache.8
man8dir = $(ROOT)/usr/share/man/man8

all: $(MANPAGES)

clean:
	rm $(MANPAGES)

install: $(MANPAGES)
	install -m 644 $(MANPAGES) $(man8dir)

uninstall:
	-(cd $(man8dir); rm -f $(MANPAGES))

%: %.pod
	pod2man -n BOOTCACHE -r"pagecache-tools 0.1" -s8 -q\" -c "Linux Page Cache Tools" <$< >$@
