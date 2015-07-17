Major kernel components of this project includes:

  * `/proc/filecache` interface for querying the pagecache
  * prioritized I/O for readahead/read requests

Major user space components of this project includes:

**`filecache`
> a tool for `/proc/filecache` (to show up in the upcoming linux kernel)**

**`bootcache`
> create/preload/defrag a set of files for some task(i.e. boot)**

**`readahead-fs`
> readahead a set of files in parallel**

When completed, the potential users can be:

  * desktop users, general purpose cache preloading
    * system boot
    * app startup
    * dir tree

  * user land support of software suspend to disk (swsusp)
    * what to drop before suspend
    * what to preload after resume

  * server adms / kernel developers
    * another view of system's file activity
    * to explore/control the page cache

This project is part of Google Summer of Code 2006, mentored by Lubos Lunak from KDE.
The SoC proposal can be found here: http://code.google.com/soc/2006/kde/appinfo.html?csaid=1F587222C2BBB5F4