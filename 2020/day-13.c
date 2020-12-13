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
            //if ( n ) {
                busses[bus_count++] = n;
            //}
            break;
        }
        if ( c == ',' ) {
            //if ( n ) {
                busses[bus_count++] = n;
                n = 0;
            //}
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
    int nz_busses[10][3];
    int maxbus = 0;
    int maxbus_idx = 0;
    for ( int i = 0; i < bus_count; i++ ) {
        if ( !busses[i] ) {
            continue;
        }
        nz_busses[nonzero_bus_count][0] = i;
        nz_busses[nonzero_bus_count][2] = 0;
        nz_busses[nonzero_bus_count++][1] = busses[i];
        int delta = busses[i] - (time % busses[i]);
        if ( delta < min_minutes ) {
            min_minutes = delta;
            min_bus = busses[i];
        }
        if ( busses[i] > maxbus ) {
            maxbus = busses[i];
            maxbus_idx = i;
        }
    }
    printf("bus nr %d, need to wait %d minutes, and magic nr is %d\n", min_bus, min_minutes, min_bus * min_minutes);
    //unsigned long k = 1;
    unsigned long b1_time = 0;
    unsigned long mul = busses[0];
    nz_busses[0][2] = 1;
    int num_found = 1;
    while ( 1 ) {
        b1_time += mul;
        int all_good = 1;
        for ( int i = 0; i < nonzero_bus_count; i++ ) {
            if ( (b1_time + nz_busses[i][0]) % nz_busses[i][1] ) {
                all_good = 0;
            } else if ( !nz_busses[i][2] ) {
                mul *= nz_busses[i][1];
                nz_busses[i][2] = 1;
            }
        }
        if ( all_good ) {
            break;
        }
    }
    printf("first good time: %lu\n", b1_time);
    printtime();
}
