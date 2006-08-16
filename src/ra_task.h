#ifndef __RA_TASK_H_
#define __RA_TASK_H_

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct RA_pages
{
  off64_t               offset;
  size_t                len;
  struct RA_pages*      next;
};

struct RA_task
{
  char*                 filename;
  int                   fn_len;
  struct RA_pages*      pages;
};

#define FREE_RA_PAGES(pages) \
  while (pages) { \
      struct RA_pages* cur = pages; \
      pages = pages->next; \
      free (cur); \
  }

#define FREE_RA_TASKP(ptask) { \
  free (ptask->filename); \
  FREE_RA_PAGES (ptask->pages); \
  free (ptask); }

#define FREE_RA_TASK(task) { \
    free (task.filename); \
    FREE_RA_PAGES (task.pages); }

void do_ra_task (struct RA_task* task);
void ra_task_destroy (struct RA_task* task);
int  ra_task_from_buf (char* buf, struct RA_task** task);
void ra_task_print (struct RA_task* task);

#endif

