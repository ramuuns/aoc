#include <stdio.h>
#include "_timer.h"

int main() {
    timer_start();
    FILE *fp = fopen("input-13","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int time;
    fscanf(fp, "%d\n", &time);
    int busses[100];
    int bus_count = 0;
    char c;
    int n = 0;
    while ( (c = fgetc(fp)) ) {
        if ( c == '\n' ) {
            busses[bus_count++] = n;
            break;
        }
        if ( c == ',' ) {
            busses[bus_count++] = n;
            n = 0;
            continue;
        }
        if ( c == 'x' ) {
            continue;
        }
        if ( c >= '0' && c <= '9' ) {
            n = n*10 + c - '0';
        }
    }
    int min_minutes = time;
    int min_bus;
    int nonzero_bus_count = 0;
    int nz_busses[10][2];
    for ( int i = 0; i < bus_count; i++ ) {
        if ( !busses[i] ) {
            continue;
        }
        nz_busses[nonzero_bus_count][0] = i;
        nz_busses[nonzero_bus_count++][1] = busses[i];
        int delta = busses[i] - (time % busses[i]);
        if ( delta < min_minutes ) {
            min_minutes = delta;
            min_bus = busses[i];
        }
    }
    printf("bus nr %d, need to wait %d minutes, and magic nr is %d\n", min_bus, min_minutes, min_bus * min_minutes);
    unsigned long b1_time = 0;
    unsigned long mul = busses[0];
    int num_found = 1;
    while ( 1 ) {
        b1_time += mul;
        int all_good = 1;
        for ( int i = 1; i < nonzero_bus_count; i++ ) { //we start from 1 because we already know that any number % bus[0] will be 0, so no need to re-confirm that 
            if ( (b1_time + nz_busses[i][0]) % nz_busses[i][1] ) {
                all_good = 0;
            } else {
                mul *= nz_busses[i][1];
                // put the last bus here in place of this one, and decrement the number of busses that we need to check
                nz_busses[i][0] = nz_busses[nonzero_bus_count - 1][0];
                nz_busses[i][1] = nz_busses[nonzero_bus_count - 1][1];
                i--; // need to check if this also happens to be a mutliple of the previous "last bus", so check again
                nonzero_bus_count--;
            }
        }
        if ( all_good ) {
            break;
        }
    }
    printf("first good time: %lu\n", b1_time);
    printtime();
}
