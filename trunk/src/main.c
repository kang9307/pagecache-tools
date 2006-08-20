#include "threadpool.h"
#include "reada.h"
#include <stdio.h> 
#include <stdlib.h>
#include <errno.h> 
#include <getopt.h>
#include <unistd.h>
#include <sys/ptrace.h>
#include <asm/unistd.h>

extern int sys_ioprio_set(int, int, int);
extern int sys_ioprio_get(int, int);

#if defined(__i386__)
#define __NR_ioprio_set         289
#define __NR_ioprio_get         290
#elif defined(__ppc__)
#define __NR_ioprio_set         273
#define __NR_ioprio_get         274
#elif defined(__x86_64__)       
#define __NR_ioprio_set         251
#define __NR_ioprio_get         252
#elif defined(__ia64__)         
#define __NR_ioprio_set         1274
#define __NR_ioprio_get         1275
#else
#error "Unsupported arch"       
#endif

_syscall3(int, ioprio_set, int, which, int, who, int, ioprio);
_syscall2(int, ioprio_get, int, which, int, who);

enum {  
        IOPRIO_CLASS_NONE,
        IOPRIO_CLASS_RT,
        IOPRIO_CLASS_BE,
        IOPRIO_CLASS_IDLE,
};

enum {  
        IOPRIO_WHO_PROCESS = 1,
        IOPRIO_WHO_PGRP,
        IOPRIO_WHO_USER,
};

#define IOPRIO_CLASS_SHIFT      13

size_t                pagesize;

int
main (int argc, char* argv[])
{
  int ret = -1;
  struct ReadA  ra;

  if (ioprio_set(IOPRIO_WHO_PROCESS, getpid(), 7 | IOPRIO_CLASS_IDLE << IOPRIO_CLASS_SHIFT) == -1) {
      perror("ioprio_set");
      return -1;
  }

  pagesize = getpagesize ();

  if (reada_init (&ra, argc, argv))
      return -1;

  if (
      !reada_dispatch (&ra) &&
      !reada_wait (&ra)
     )
      ret = 0;

  reada_destroy (&ra);

  return ret;
}
