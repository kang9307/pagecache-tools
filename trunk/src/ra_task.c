#include "ra_task.h"
#include <nptl/pthread.h>


extern int pagesize;

int
ra_task_pages (char* p, struct RA_pages** pages)
{
  char*            e;
  struct RA_pages* cur;

  unsigned int  offset;
  unsigned int  len;

  *pages = NULL;
  cur    = NULL;
  e      = p;

  while (e != NULL)
    {
      e = strchr (p, '\n');

      if (e != NULL)
          *e = 0;

      if (*p != '#')
        {
          sscanf (p, "%u\t%u\n", &offset, &len);

          if (cur == NULL)
            {
              cur = (struct RA_pages*) malloc (sizeof (struct RA_pages));
              *pages = cur;
            }
          else
            {
              cur->next = (struct RA_pages*) malloc (sizeof (struct RA_pages));
              cur = cur->next;
            }

          cur->offset = offset * pagesize;
          cur->len    = len * pagesize;
          cur->next   = NULL;
        }

      p = e + 1;
    }

  if (cur == NULL)
      return -1;

  return 0;
}

void
ra_task_print (struct RA_task* task)
{
  struct RA_pages* cur = task->pages;

  printf ("%s\n", task->filename);

  while (cur)
    {
      printf ("%u\t%u\n", (unsigned)(cur->offset/pagesize), (unsigned)(cur->len/pagesize));
      cur = cur->next;
    }

  printf ("\n");
}


int
ra_task_from_buf (char* buf, struct RA_task** task)
{
  char* e;

  if (buf == NULL || task == NULL || *buf != '/')
      return -1;

  e = strchr (buf, '\n');

  if (e == NULL)
      return -1;

  *e = 0;
  if (e - buf != 0)
    {
      *task = (struct RA_task*) malloc (sizeof(struct RA_task));

      if (*task)
        {
          (*task)->fn_len = e - buf;
          (*task)->filename = strndup (buf, (*task)->fn_len);

          buf = ++e;

          if (ra_task_pages (buf, &(*task)->pages) == -1)
            {
              FREE_RA_TASKP((*task));
              *task = NULL;
            }
          else
              return 0;
        }
    }

  return -1;
}

void
ra_task_destroy (struct RA_task* task)
{
  FREE_RA_TASKP(task);
}

void
do_ra_task (struct RA_task* task)
{
  int           ret;
  int           fd;
  struct RA_pages* pages;

/* #ifdef _DEBUG */
          /* ra_task_print (task); */
/* #endif */

  pages = task->pages;

      fd = open(task->filename, O_RDONLY | O_LARGEFILE);
      if (fd == -1) {
          perror(task->filename);
          return;
      }

      while (pages != NULL)
        {
          ret    = readahead(fd, pages->offset, pages->len);

          if (ret == -1)
            {
                  perror(task->filename);
                  break;
            }
          pages = pages->next;
        }

  close(fd);
}

