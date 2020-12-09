#include <stdio.h>
#include "_timer.h"

#define BUFFER_SIZE 25

int main() {
    timer_start();
    FILE *fp = fopen("input-09","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    unsigned int buffer[BUFFER_SIZE];
    int buff_idx = 0;
    int buffer_filled = 0;
    unsigned int current_nr;
    while ( fscanf(fp, "%u\n", &current_nr ) ) {
        if ( buffer_filled ) {
            int ok = 0;
            for ( int i = 0; i < BUFFER_SIZE; i++ ) {
                for ( int j = i + 1; j < BUFFER_SIZE; j++ ) {
                    if ( current_nr == buffer[i] + buffer[j] ) {
                        ok = 1;
                        break;
                    }
                }
                if ( ok ) {
                    break;
                }
            }
            if ( ! ok ) {
                break;
            }
        }
        buffer[buff_idx] = current_nr;
        buff_idx = (buff_idx + 1) % BUFFER_SIZE;
        if ( !buffer_filled && buff_idx == 0 ) {
            buffer_filled = 1;
        }
    }
    printf("first bad nr: %u\n", current_nr);
    unsigned int tgt_nr = current_nr;
    unsigned int sum = 0;
    unsigned int window[1000];
    int w_st = 0;
    int w_end = 0;
    fseek(fp, 0, SEEK_SET);
    int i = 0;
    while ( fscanf(fp, "%u\n", &current_nr ) ) {
        if ( sum + current_nr == tgt_nr ) {
            window[w_end] = current_nr;
            break;
        }
        while ( sum + current_nr > tgt_nr ) {
            sum -= window[w_st];
            w_st = (w_st + 1) % 1000; 
        }
        sum += current_nr;
        window[w_end] = current_nr;
        if ( sum == tgt_nr ) {
            break;
        }
        w_end = (w_end+1) % 1000;
        i++;
        if ( i == 1100 ) {
            return 1;
        }
    }
    fclose(fp);
    unsigned int min = window[w_st];
    unsigned int max = window[w_st];
    do {
        w_st = (w_st + 1) % 1000;
        min = min > window[w_st] ? window[w_st] : min;
        max = max < window[w_st] ? window[w_st] : max;
    } while ( w_st != w_end );
    printf("sum of min and max: %u\n", min+max);
    printtime();
}
