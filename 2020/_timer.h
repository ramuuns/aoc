#ifndef __AOC_TIMER_H
#define __AOC_TIMER_H
#include <time.h>

struct timespec start;

void timer_start() {
    clock_gettime(CLOCK_MONOTONIC, &start);
}

void printtime() {
    struct timespec end;
    clock_gettime(CLOCK_MONOTONIC, &end);
    double time_taken;
    time_taken = (end.tv_sec - start.tv_sec) * 1e9;
    time_taken = (time_taken + (end.tv_nsec - start.tv_nsec)) * 1e-9;
    printf("time: %f\n", time_taken);
}


#endif
