#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

#define INITIAL_COUNT 6
#define INITIAL_NUMBERS 2,1,10,11,0,6

#define HASH_SIZE 30000000

int main() {
    timer_start();
    int initial_numbers[INITIAL_COUNT] = { INITIAL_NUMBERS };
    int *nr_seen_at = calloc(HASH_SIZE, sizeof(int));

    int i = 1;
    int num = 0;

    while ( i < INITIAL_COUNT ) {
        num = initial_numbers[i-1];
        nr_seen_at[num] = i++;
    }

    int prev = initial_numbers[INITIAL_COUNT - 1 ];

    int limits[2] = {2020, 30000000};
    for ( int k = 0; k < 2; k++ ) {

        while ( i < limits[k] ) {
            num = nr_seen_at[prev] ?( i - nr_seen_at[prev] ) : 0;
            nr_seen_at[prev] = i++;
            prev = num;
        }

        printf("turn %d nr: %d\n", i, num);

    }

    printtime();
}
