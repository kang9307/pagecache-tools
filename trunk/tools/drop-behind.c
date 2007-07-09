/*
 * drop-behind: run a command and drop behind large sequential files it read.
 *
 * (C) July 2007, Fengguang Wu <wfg@ustc.edu>
 *
 * Compile:
 * 	gcc -o drop-behind drop-behind.c
 * Run:
 * 	drop-behind xterm
 *
 * To control your pagecache in a more comprehensive way,
 * try Andrew Morton's pagecache management tool at:
 * <http://userweb.kernel.org/~akpm/pagecache-management/>
 */

#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

void usage(void)
{
	puts("drop-behind <cmd> [args]");
	puts("Run a command without flushing the pagecache with large sequential file reads.");
}

int main(int argc, char *argv[])
{
	int ret;

	if (argc < 2) {
		usage();
		exit(0);
	}

	ret = posix_fadvise(-1, 0, 0, POSIX_FADV_NOREUSE);
	if (ret) {
		fprintf(stderr, "%s: posix_fadvise() failed: %s\n",
				argv[0], strerror(errno));
		exit(1);
	}

	ret = execvp(argv[1], argv + 1);
	if (ret) {
		fprintf(stderr, "%s: execvp(%s) failed: %s\n",
				argv[0], argv[1], strerror(errno));
		exit(2);
	}
}
