#include "reada.h"
#include "ra_task.h"
#include <getopt.h>

struct reada_options
{
  char*         input_file;
  size_t        max_threads;
  size_t        max_queue_size;
};

int
ra_thread_func (struct thread_pool_t* tp)
{
  struct RA_task* task;

  while (tp_popq (tp, (void*)&task) != -1)
    {
      do_ra_task (task);
      tp->rt_destroy (task);
    }
  return 0;
}

int
reada_fill_buf (struct ReadA* ra)
{
  int   ret;

  while (ra->buf[ra->pos] == 0)
    {
      ret = read (ra->fd, ra->buf + ra->pos, BUFSIZE - ra->pos - 1); 

      if (ret == -1)
        {
          if (errno == EINTR)
              continue;
          else if (errno == EBADF)
            {
              perror(ra->input);
              ra->fd = open(ra->input, O_RDONLY);
              if (ra->fd == -1) {
                  perror(ra->input);
                  return -1;
              }
              lseek (ra->fd, ra->offset, SEEK_SET);
              continue;
            }
          else
            {
              perror(ra->input);
              return -1;
            }
        }
      else if (ret == 0)
          return -1; /* EOF */

      ra->offset += ret;

      ra->len = ret + ra->pos;
      ra->buf[ra->len] = 0;
      ra->pos = 0;
    }

  return 0;
}

int
reada_fetch_one_item (struct ReadA* ra, char** item)
{
  int   ret;
  char* p;
  char* e;


  if (item == NULL || reada_fill_buf (ra) == -1) {
	  /* fprintf(stderr, "null item or initial reada_fill_buf error, maybe EOF hit\n"); */
      return -1;
  }

  *item = 0;

  p = ra->buf + ra->pos;
  while (*p != 0)
    {
      if (*p == '%' || *p == '/')
        {
          e = strstr (p, "\n\n");

          if (e == NULL)
            {
              if (ra->pos == 0) {
		      fprintf(stderr, "BUFSIZE too small\n");
                  return -1; /* BUFSIZE is to small ? */
	      }

              /* need more data from file */

              ret = strlen (p);

              if (ret)
                {
                  memmove (ra->buf, p, ret);
                  ra->buf[ret] = 0;
                }

              ra->pos = ret;

              if (reada_fill_buf (ra) == -1) {
		      fprintf(stderr, "reada_fill_buf error\n");
                  return -1;
	      }

              p = ra->buf + ra->pos;

              continue;
            }

          *e++ = 0; *e++ = 0;
          ra->pos = e - ra->buf; 
          *item = p;
          return 0;
        }
      else
          ++p;
    }

  return -1;
}

void 
print_help (const char* prog)
{
  fprintf (stderr, "Usage: %s [-t max_threads] input_file\n\n", prog);
  fprintf (stderr, 
      "This program readaheads the pages of a file list according to\n"
      "the information from \"input_file\". Here the muti-threads method\n"
      "is used that let the kernel scheduler sort the real calls to the\n"
      "harddisk, for the list from \"input_file\" isn't locally superior.\n"
      "The default number of threads is \"20\" and can be modified by\n"
      "using the option \"-t\".\n\n" 
      );
}

int
parse_options (struct reada_options* options, int argc, char* argv[])
{
  int c;

  options->input_file  = NULL;
  options->max_threads = 0;
  options->max_queue_size = 0;

  while ((c = getopt (argc, argv, "t:q:h")) != -1)
    {
      switch(c)
        {
          case 't':
            options->max_threads = atoi (optarg);
            break;
          case 'q':
            options->max_queue_size = atoi (optarg);
            break;
          case 'h':
            print_help (argv[0]);
            return -1;
        }
    }

  if (optind < argc)
      options->input_file = argv[optind];
  else
    {
      print_help (argv[0]);
      return -1;
    }
  
  if (options->max_threads == 0)
      options->max_threads = 20;
        
  if (options->max_queue_size == 0)
      options->max_queue_size = 100;

  return 0;
}

int 
reada_init (struct ReadA* ra, int argc, char* argv[])
{
  /* char*                 p; */
  struct reada_options  options; 

  if (parse_options (&options, argc, argv) == -1)
      return -1;

  ra->input = options.input_file;
  ra->fd    = -1;
  ra->offset    = 0;
  ra->buf[0]    = 0;
  ra->pos       = 0;
  /* ra->partition = NULL; */
  /* ra->moutpoint = NULL; */
  /* ra->fstype    = NULL; */

  if (tp_init (&ra->tp, options.max_threads, options.max_queue_size, ra_thread_func, 
        (real_task_destroy)ra_task_destroy) == -1)
      return -1;

  ra->fd = open(ra->input, O_RDONLY);
  if (ra->fd == -1) {
      perror(ra->input);
      tp_destroy (&ra->tp);
      return -1;
  }

#if 0
  if (reada_fetch_one_item (ra, &p) == -1 || *p != '%')
    {
      /* *p != '%' wrong file format ! */
      close(ra->fd);
      tp_destroy (&ra->tp);
      return -1;
    }

  if (reada_device_info (ra, p) == -1)
    {
      /* wrong file format ! */
      close(ra->fd);
      tp_destroy (&ra->tp);
      if (ra->partition)
          free (ra->partition);
      if (ra->moutpoint)
          free (ra->moutpoint);
      if (ra->fstype)
          free (ra->fstype);
      return -1;
    }

#ifdef _DEBUG
  printf ("partition: %s\nmountpoint: %s\nfstype: %s\n\n",
      ra->partition, ra->moutpoint, ra->fstype);
#endif
#endif

  return 0;
}

int
reada_dispatch (struct ReadA* ra)
{
  struct RA_task* task;
  char *p;

#if 0
  if (reada_fetch_one_item (ra, &p) == -1) 
      return -1;

  if (ra_task_from_buf (p, &task) != -1)
    {
#ifdef _DEBUG
      ra_task_print (task);
#endif

      if (strcmp (task->filename, ra->partition) == 0)
        {
          do_ra_task (task);
          FREE_RA_TASKP (task);
        }
      else
        {
          /* wrong file format */
          FREE_RA_TASKP (task);
          return -1;
        }
    }
#endif

  while (reada_fetch_one_item (ra, &p) != -1)
    {
      if (ra_task_from_buf (p, &task) != -1)
        {
#ifdef _DEBUG
      ra_task_print (task);
#endif
          tp_pushq (&ra->tp, task);
        }
    }

  return tp_send_control (&ra->tp, TP_TASK_CONTROL_TERM);
}

int 
reada_wait (struct ReadA* ra)
{
  return tp_wait (&ra->tp);
}

int 
reada_destroy (struct ReadA* ra)
{
  int ret;

  ret = tp_destroy (&ra->tp);
  /* free (ra->partition); */
  /* free (ra->moutpoint); */
  /* free (ra->fstype); */
  close (ra->fd);

  return ret;
}

