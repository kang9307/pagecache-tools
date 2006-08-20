/*
* eatmem.c -- allocate a junk of memory and make it dirty
* Copyright Harald Koenig <koenig@tat.physik.uni-tuebingen.de> 1994
*
* Permission is hereby granted to copy, modify and redistribute this code
* in terms of the GNU Library General Public License, Version 2 or later,
* at your option.
*
* to compile use
* cc -O2 -Wall -fomit-frame-pointer -s -o eatmem eatmem.c
*/

/*
	Modified by Frank Sorenson <frank@tuxrocks.com> 2005
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <malloc.h>
#include <string.h>

int signal_caught = 0;

void signal_handler(int sig)
{
	pid_t pgrp;

	if (signal_caught > 0) return;
	signal_caught ++;
	pgrp = getpgrp();
	killpg(pgrp, sig);
}

long int get_mem_size(char *size)
{
	long int mem_size = (-1);
	char *ptr;

	mem_size = strtoul(size, &ptr, 10);
	switch (ptr[0]) {
		case 'M' :
		case 'm' :
			mem_size *= 1024;
			break;
		case 'G' :
		case 'g' :
			mem_size *= 1024*1024;
			break;
		case 'K' :
		case 'k' :
		default  :
			break;
	}
	return mem_size;
}

void setup_handlers()
{
	/* setup the signal handler */
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGCHLD, signal_handler);
}

void dirty_mem(char *mem, long int mem_size)
{
	int i;
	char *pmem = mem;

	for (i = 0; i < mem_size; i++) {
		(*pmem)++;
		pmem += 1024;
	}
}

int main(int argc, char *argv[])
{
	char *mem=NULL,*pb;
	long int mem_size = (-1);
	int err = 0;
	int num_threads = 1;
	pid_t pid;
	pid_t ppid;
	int thread_id;

	if (argc >= 2) {
		mem_size = get_mem_size(argv[1]);
		if (argc == 3)
			num_threads = strtoul(argv[2], &pb, 10);
		else if (argc > 3)
			err=1;
	}

	if (mem_size <= 0 || err) {
		fprintf(stderr,"usage: %s size[K|M|G] [num_of_threads]\n", argv[0]);
		exit(1);
	}

	for (thread_id = 0; thread_id < (num_threads - 1) ; thread_id ++) {
		pid = fork();
		if (pid == 0) break;
	}
	ppid = getppid();

	mem = malloc(mem_size*1024);
	if (mem == NULL) {
		fprintf(stderr,"malloc failed.\n");
		exit(1);
	}

	if (num_threads == 1)
		signal_caught ++;
	else
		setup_handlers();

	do {
		dirty_mem(mem, mem_size);

		/* if parent has died... */
		/* there's got to be a better way, though */
		if (thread_id != 0 && getppid() != ppid)
			killpg(getpgrp(), SIGTERM);
	} while (signal_caught == 0);

	if (num_threads == 1)
		kill(0, SIGSTOP);

	free(mem);
	exit(0);
}

