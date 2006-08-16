/**
 * 
 * @file        test.c
 * 
 * @brief       测试threadpool。 
 * 
 * @version     1.0
 * @date        2006年07月18日 18时41分17秒 CST
 * 
 * @author      C.F. Xu <johnx@ustc.edu>
 * 
 */

#include "threadpool.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int 
test_thread_func (struct thread_pool_t* tp)
{
  char* rt;

  printf ("this is the thread %lu.\n", pthread_self ()); 

  while (tp_popq (tp, (void*)&rt) != -1)
    {
      printf ("[%lu]:\t %s.\n", pthread_self(), rt);

      tp->rt_destroy (rt);

      sleep (1);
    }

  return 0;
}

void 
rt_free (void* rt)
{
  free (rt);
}

void
parse (int argc, char* argv[])
{
  int c;
   
  while ((c = getopt (argc, argv, "abc:d::ef")) != -1)
    {
      switch(c)
        {
          case 'a':
          case 'b':
          case 'e':
          case 'f':
            printf ("option -%c.\n", c);
            break;
          case 'c':
            printf ("option -%c with arg %s.\n", c, optarg);
            break;
          case 'd':
            if (optarg)
                printf ("option -%c with arg %s.\n", c, optarg);
            else
                printf ("option -%c.\n", c);
            break;
          default:
            break;
            /* printf (" Unknown option -%c.\n", c); */
        }
    }

  while (optind < argc)
      printf ("non-option arg %s.\n", argv[optind++]);
} 

int
main (int argc, char* argv[])
{
  int i;
  char* hello;
  struct thread_pool_t tp;

  /* parse(argc, argv); */

  /* return 0; */

  tp_init (&tp, 10, 5, test_thread_func, rt_free);

  for (i = 0; i < 50; ++i)
    {
      /* printf ("dispath %d.\n", i); */
      hello = (char*) malloc (50*sizeof(char));
      sprintf (hello, "hello world %d", i);
      tp_pushq (&tp, (void*) hello);
      /* sleep (2); */
    }

  tp_send_control (&tp, TP_TASK_CONTROL_TERM);
  tp_wait (&tp);

  tp_destroy (&tp);
  return 0;
}

