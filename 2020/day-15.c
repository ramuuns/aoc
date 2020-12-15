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
    int *nr_diff_at = calloc(HASH_SIZE, sizeof(int));

    int i = 1;
    int num = 0;

    while ( i <= INITIAL_COUNT ) {
        num = initial_numbers[i-1];
        nr_seen_at[num] = i;
        i++;
    }

    int is_seen = 0;
    int limits[2] = {2020, 30000000};
    for ( int k = 0; k < 2; k++ ) {

        while ( i <= limits[k] ) {
            if ( is_seen ) {
                num = nr_diff_at[num];
                is_seen = nr_seen_at[num];
                if ( is_seen ) {
                    nr_diff_at[num] = i - nr_seen_at[num];
                }
                nr_seen_at[num] = i;
            } else {
                num = 0;
                is_seen = 1;
                nr_diff_at[0] = i - nr_seen_at[0];
                nr_seen_at[0] = i;
            }
            i++;
        }

        printf("turn %d nr: %d (is new: %d)\n", i-1, num, is_seen);

    }

    printtime();
}
