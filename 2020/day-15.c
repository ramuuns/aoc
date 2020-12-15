#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

#define INITIAL_COUNT 6
#define INITIAL_NUMBERS 2,1,10,11,0,6

int main() {
    timer_start();
    int initial_numbers[INITIAL_COUNT] = { INITIAL_NUMBERS };
    long *nr_seen_at = malloc(30000000 * 2 * sizeof(long)); //[2020][2] =  // = { {-1, 0} };
    for ( int i = 0; i < 30000000; i++ ) {
        *(nr_seen_at+(i<<1)) = -1;
        *(nr_seen_at+(i<<1)+1) = 0;
    }
    printtime();

    unsigned int i = 1;
    long pseen_at = 0;
    unsigned int num = 0;

    while ( i <= 30000000 ) {
        if ( i <= INITIAL_COUNT ) {

            num = initial_numbers[i-1];
            pseen_at = *(nr_seen_at + (num << 1));
            *(nr_seen_at + (num << 1)) = i;
        } else {
            if ( pseen_at == -1 ) {
                num = 0;
                pseen_at = *nr_seen_at;
                *(nr_seen_at+1) = i - *nr_seen_at;
                *nr_seen_at = i;
            } else {
                num = *(nr_seen_at + (num << 1) + 1);
                pseen_at = *(nr_seen_at + (num << 1));
                if ( pseen_at > -1 ) {
                    *(nr_seen_at + (num << 1) + 1) = i - *(nr_seen_at + (num <<1));
                }
                *(nr_seen_at + (num << 1)) = i;
            }
        }
        if ( i == 2020 ) {
            printf("turn %u nr :%u (pseen at %ld)\n", i, num, pseen_at);
        }
        i++;
    }
    printf("turn %u nr :%u (pseen at %ld)\n", i, num, pseen_at);

    printtime();
}
