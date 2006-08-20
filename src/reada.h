#ifndef __READA_H_
#define __READA_H_ 

#include "threadpool.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BUFSIZE (10*BUFSIZ)

struct ReadA
{
  char*                 input;   /* 保存预读任务文件的名称  */
  int                   fd;
  size_t                offset;
  char                  buf[BUFSIZE];
  size_t                len;
  size_t                pos;
  // char*                 partition;
  // char*                 moutpoint;
  // char*                 fstype;
  // char*                 device;
  struct thread_pool_t  tp;
};

int reada_init (struct ReadA* ra, int argc, char* argv[]);
int reada_dispatch (struct ReadA* ra);
int reada_wait (struct ReadA* ra);
int reada_destroy (struct ReadA* ra);

#endif

