#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "fadvise.h"

char *progname;

static void usage(void)
{
	fprintf(stderr, "Usage: %s filename offset length advice\n", progname);
	fprintf(stderr, "      advice: normal sequential willneed noreuse "
					"dontneed\n");
	exit(1);
}

int
main(int argc, char *argv[])
{
	int c;
	int fd;
	char *sadvice;
	char *filename;
	loff_t offset;
	unsigned long length;
	int advice = 0;
	int ret;

	progname = argv[0];

	while ((c = getopt(argc, argv, "")) != -1) {
		switch (c) {
		}
	}

	if (optind == argc)
		usage();
	filename = argv[optind++];

	if (optind == argc)
		usage();
	offset = strtoull(argv[optind++], NULL, 0);

	if (optind == argc)
		usage();
	length = strtol(argv[optind++], NULL, 0);

	if (optind == argc)
		usage();
	sadvice = argv[optind++];

	if (optind != argc)
		usage();

	if (!strcmp(sadvice, "normal"))
		advice = POSIX_FADV_NORMAL;
	else if (!strcmp(sadvice, "sequential"))
		advice = POSIX_FADV_SEQUENTIAL;
	else if (!strcmp(sadvice, "willneed"))
		advice = POSIX_FADV_WILLNEED;
	else if (!strcmp(sadvice, "noreuse"))
		advice = POSIX_FADV_NOREUSE;
	else if (!strcmp(sadvice, "dontneed"))
		advice = POSIX_FADV_DONTNEED;
	else
		usage();

	fd = open(filename, O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "%s: cannot open `%s': %s\n",
			progname, filename, strerror(errno));
		exit(1);
	}

	ret = __posix_fadvise64(fd, offset, length, advice);
	if (ret) {
		fprintf(stderr, "%s: fadvise() failed: %s\n",
			progname, strerror(errno));
		exit(1);
	}
	close(fd);
	exit(0);
}
