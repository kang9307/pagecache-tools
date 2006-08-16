#include "threadpool.h"
#include <stdlib.h>
#include <stdio.h>

int 
tp_queue_init (struct tp_queue* tpq, size_t max_size)
{
  if (pthread_mutex_init (&tpq->lock_mutex, NULL) != 0)
      return -1;

  if (pthread_cond_init (&tpq->not_empty_cond, NULL) != 0)
    {
      pthread_mutex_destroy (&tpq->lock_mutex);
      return -1;
    }

  if (pthread_cond_init (&tpq->not_full_cond, NULL) != 0)
    {
      pthread_mutex_destroy (&tpq->lock_mutex);
      pthread_cond_destroy (&tpq->not_empty_cond);
      return -1;
    }

  tpq->length = 0;
  tpq->head   = NULL;
  tpq->tail   = NULL;
  tpq->active = 1;
  if (max_size == 0)
      tpq->max_size = (size_t) -1;
  else
      tpq->max_size = max_size;

  return 0;
}

int
tp_queue_destroy (struct tp_queue* tpq)
{
  int ret = 0;

  if (tpq->active == -1)
      return 0;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  if (tpq->length != 0)
    {
      pthread_mutex_unlock (&tpq->lock_mutex);
      return -1;
    }

  tpq->active = -1;

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  ret  =  pthread_mutex_destroy (&tpq->lock_mutex);
  ret += pthread_cond_destroy (&tpq->not_empty_cond);
  ret += pthread_cond_destroy (&tpq->not_full_cond);

  if (ret != 0)
      return -1;

  return 0;
}

int
tp_queue_push (struct tp_queue* tpq, void* real_task, int* flags)
{
  int ret = -1;


  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  if (real_task == NULL && flags == NULL && tpq->active == 1)
      ret = tpq->length;

  if (tpq->active == 1 && (real_task || flags))
    {
      while (tpq->length > tpq->max_size)
        {
          if (pthread_cond_wait (&tpq->not_full_cond, &tpq->lock_mutex) || tpq->active <= 0)
            {
              pthread_mutex_unlock (&tpq->lock_mutex);
              return -1;
            }
        }

      struct tp_task* tpt = (struct tp_task*) malloc (sizeof (struct tp_task));

      if (tpt != NULL)
        {
          if (flags == NULL)
              tpt->flags = 0;
          else
              tpt->flags = *flags;
          tpt->real_task = real_task; 
          tpt->next = NULL; 
          if (tpq->tail != NULL)
              tpq->tail->next = tpt;
          else
              tpq->head = tpt;
          tpq->tail = tpt;
          ret = ++tpq->length;
          pthread_cond_signal (&tpq->not_empty_cond);
        }
    }

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return ret;;
}

int
tp_queue_pop (struct tp_queue* tpq, void** real_task, int* flags)
{
  int ret = -1;

  *real_task = NULL;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  if (tpq->active == 1)
    {
      while (tpq->length == 0)
        {
          if (pthread_cond_wait (&tpq->not_empty_cond, &tpq->lock_mutex) ||  tpq->active <= 0)
            {
              pthread_mutex_unlock (&tpq->lock_mutex);
              return -1;
            }
        }

      struct tp_task* tpt = tpq->head;
      *real_task = tpt->real_task;
      tpq->head = tpq->head->next;
      if (tpq->head == NULL)
          tpq->tail = NULL;
      if (flags)
          *flags = tpt->flags;
      free (tpt);
      ret = --tpq->length;
      pthread_cond_signal (&tpq->not_full_cond);
    }

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return ret;
}

int 
tp_queue_activate (struct tp_queue* tpq)
{
  if (tpq->active == -1)
      return -1;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  tpq->active = 1;

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return 0;
}

int 
tp_queue_deactivate (struct tp_queue* tpq)
{
  if (tpq->active == -1)
      return -1;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  tpq->active = 0;

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return 0;
}

size_t 
tp_queue_size (struct tp_queue* tpq)
{
  size_t size = 0;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  size = tpq->length;

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return size;
}

int
tp_queue_active (struct tp_queue* tpq)
{
  size_t active = 0;

  if (pthread_mutex_lock (&tpq->lock_mutex) != 0)
      return -1;

  active = tpq->active == 1;

  if (pthread_mutex_unlock (&tpq->lock_mutex) != 0)
      return -1;

  return active;
}

int 
tp_pushq (struct thread_pool_t* tp, void* real_task)
{
  return tp_queue_push (&tp->tpq, real_task, NULL);
}

int 
tp_popq (struct thread_pool_t* tp, void** real_task)
{
  int ret, flags;
  ret = tp_queue_pop (&tp->tpq, real_task, &flags);
  if (ret != -1 && flags == TP_TASK_CONTROL_TERM)
      ret = -1;
  return ret;
}

void* tp_thread_func (void* arg)
{
  struct thread_pool_t* tp; 
  thread_func_t tf; 

  tp = (struct thread_pool_t*) arg;
  tf = (thread_func_t) tp->thread_func;

  tf (tp);

  return NULL;
}

int 
tp_init (struct thread_pool_t* tp, size_t nthread, size_t max_queue_size,
    thread_func_t tf, real_task_destroy rt_destroy)
{
  int j;

  if (tf == NULL || rt_destroy == NULL || tp == NULL || nthread == 0)
      return -1;

  if (tp_queue_init (&tp->tpq, max_queue_size) == -1)
      return -1;

  tp->nthread = nthread;
  tp->thread_func = tf;
  tp->rt_destroy = rt_destroy;

  tp->threads = (pthread_t*) malloc (nthread * sizeof(pthread_t));

  if (tp->threads == NULL)
    {
      tp_destroy (tp);
      return -1;
    }

  for (j = 0; j < nthread; ++j) {
      if (pthread_create (&tp->threads[j], NULL, tp_thread_func, (void*)tp) != 0)
        {
          tp_destroy (tp);
          return -1;
        }
  }

  return 0;
}

int 
tp_destroy (struct thread_pool_t* tp)
{
  void* real_task;

  tp_send_control (tp, TP_TASK_CONTROL_TERM);

  tp_queue_deactivate (&tp->tpq);

  tp_wait (tp);

  tp_queue_activate (&tp->tpq);

  while (tp_queue_size(&tp->tpq))
    {
      tp_queue_pop (&tp->tpq, &real_task, NULL);
      if (real_task != NULL)
          tp->rt_destroy (real_task);
    }

  if (tp->threads)
      free (tp->threads);

  tp->threads = NULL;

  return tp_queue_destroy (&tp->tpq);
}

int 
tp_wait (struct thread_pool_t* tp)
{
  unsigned int i;

  for (i = 0; i < tp->nthread; ++i)
      pthread_join (tp->threads[i], NULL);

  tp->nthread = 0;

  return 0;
}

int
tp_send_control (struct thread_pool_t* tp, int control)
{
  int ret, i;

  for (ret = 0, i = 0; i < tp->nthread; ++i)
      if (tp_queue_push (&tp->tpq, NULL, &control) == -1)
          ret = -1;

  return ret;
}

