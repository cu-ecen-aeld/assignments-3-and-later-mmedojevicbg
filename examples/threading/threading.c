#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{
    struct thread_data* data = (struct thread_data*) thread_param;
    struct timespec sleep_time;
    sleep_time.tv_sec = data->wait_to_obtain_ms / 1000;
    sleep_time.tv_nsec = (data->wait_to_obtain_ms % 1000) * 1000000;
    nanosleep(&sleep_time, NULL);
    if (pthread_mutex_lock(data->mutex) != 0) {
        data->thread_complete_success = false;
        return (void*) data;
    }
    sleep_time.tv_sec = data->wait_to_release_ms / 1000;
    sleep_time.tv_nsec = (data->wait_to_release_ms % 1000) * 1000000;
    nanosleep(&sleep_time, NULL);
    if (pthread_mutex_unlock(data->mutex) != 0) {
        data->thread_complete_success = false;
        return (void*) data;
    }
    data->thread_complete_success = true;
    return (void*) data;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    struct thread_data* data = (struct thread_data*) malloc(sizeof(struct thread_data));
    if (!data) {
        perror("Failed to allocate memory for thread data");
        return false;
    }
    data->mutex = mutex;
    data->wait_to_obtain_ms = wait_to_obtain_ms;
    data->wait_to_release_ms = wait_to_release_ms;
    data->thread_complete_success = false;
    int result = pthread_create(thread, NULL, threadfunc, (void*) data);
    if (result != 0) {
        perror("Failed to create thread");
        free(data);
        return false;
    }
    return true;
}

