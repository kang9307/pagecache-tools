#ifndef __THREAD_POOL_H__
#define __THREAD_POOL_H__

#include <pthread.h>


#define TP_TASK_DATA_MASK 0x00000000

#define TP_TASK_CONTROL_MASK 0xFFFF0000
#define TP_TASK_CONTROL_TERM 0xFFFF0000

struct tp_task
{
  void* real_task;
  struct tp_task* next;
  int flags;
};

struct tp_queue
{
  int    active;
  size_t length;
  size_t max_size;
  struct tp_task* head;
  struct tp_task* tail;
  pthread_mutex_t lock_mutex;
  pthread_cond_t  not_empty_cond;
  pthread_cond_t  not_full_cond;
};

typedef void (*real_task_destroy)(void*);

struct thread_pool_t
{
  struct tp_queue tpq;
  size_t nthread;
  pthread_t* threads;
  void* thread_func;
  real_task_destroy rt_destroy;
};

typedef int (*thread_func_t)(struct thread_pool_t*); 

int tp_queue_init (struct tp_queue* tpq, size_t max_size);
int tp_queue_destroy (struct tp_queue* tpq);
int tp_queue_push (struct tp_queue* tpq, void* real_task, int* flags); 
int tp_queue_pop (struct tp_queue* tpq, void** real_task, int* flags); 
int tp_queue_active (struct tp_queue* tpq);
int tp_queue_activate (struct tp_queue* tpq);
int tp_queue_deactivate (struct tp_queue* tpq);
size_t tp_queue_size (struct tp_queue* tpq);

int tp_init (struct thread_pool_t* tp, size_t nthread, size_t max_queue_size, 
    thread_func_t tf, real_task_destroy rt_destroy);
int tp_destroy (struct thread_pool_t* tp);
int tp_wait (struct thread_pool_t* tp);

int tp_pushq (struct thread_pool_t* tp, void* real_task);
int tp_popq (struct thread_pool_t* tp, void** real_task);

int tp_send_control (struct thread_pool_t* tp, int control);

#endif

