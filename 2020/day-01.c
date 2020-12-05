#include <stdio.h>
#include "_timer.h"

int main() {
    timer_start();
    FILE *fp = fopen("input-01","r");
    if ( !fp ) {
        printf("could not open file\n");
        return 1;
    }
    char buff[255];
    int data[255];
    char nr_map[2020] = { 0 };
    int nr_rows = 0;
    int a, b;
    while (fgets(buff, 255, fp) ) {
        sscanf(buff, "%d", &data[nr_rows]);
        if ( !data[nr_rows] ) {
            continue;
        }
        if ( 2020 - data[nr_rows] > 0 && nr_map[2020 - data[nr_rows]] ) {
            a = data[nr_rows];
            b = 2020 - data[nr_rows];
        }
        if ( 2020 - data[nr_rows] > 0 ) {
            nr_map[data[nr_rows]] = 1;
        }
        nr_rows++;
    }

    printf("a*b = %d\n", a*b);
    int c = 0;
    for ( int i = 0; i < nr_rows; i++ ) {
        for ( int j = i; j < nr_rows; j++ ) {
            if ( 2020 - ( data[i] + data[j] ) > 0 && nr_map[ 2020 - ( data[i] + data[j] ) ] ) {
                a = data[i];
                b = data[j];
                c = 2020 - a - b;
                break;
            }
        }
        if ( c ) {
            break;
        }
    }
    printf("a*b*c = %d\n", a*b*c); 
    printtime();
}
