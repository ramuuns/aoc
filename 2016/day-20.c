#include <stdio.h>
#include <stdlib.h>

#define MAXNUM 0xFFFFFFFF

typedef struct _rec {
    unsigned int start;
    unsigned int end;
} rec;

int compar(const void *a, const void *b) {
    rec _a = *( rec* )a;
    rec _b = *( rec* )b;
    if ( _a.start == _b.start ) {
        return _a.end > _b.end ? 1 : -1;
    }
    return _a.start > _b.start ? 1 : -1;
}

int main() {
    unsigned int nr_ranges = 0;
    FILE *fp = fopen("input-20","r");
    if ( !fp ) {
        printf("cannot open the file\n");
        exit(1);
    }
    char buff[255];
    while ( fgets(buff, 255, fp) ) {
        nr_ranges++;
    }
    fseek(fp, 0, SEEK_SET);
    unsigned int a, b;
    rec arr[nr_ranges];

    int i = 0;
    while( fgets(buff, 255, fp) ) {
        sscanf(buff, "%u-%u", &arr[i].start, &arr[i].end);
        i++;
    }
    fclose(fp);

    qsort(arr, nr_ranges, sizeof( rec ), compar);
/*
    for ( int i =0; i < nr_ranges; i++ ) {
        printf("%u - %u\n", arr[i].start, arr[i].end);
    }
*/
    unsigned int min_addr = 0;
    unsigned int rangemax = arr[0].end;
    if ( arr[0].start > 0 ) {
        printf("lowest address: 0\n");
        exit(0);
    }
    i = 1;
    while ( min_addr == 0 && i < nr_ranges ) {
        if ( arr[i].start > rangemax + 1 ) {
            min_addr = rangemax+1;
        } else {
            rangemax = rangemax < arr[i].end ? arr[i].end : rangemax;
            i++;
        }
    }
    if ( min_addr == 0 && rangemax < MAXNUM ) {
        min_addr = rangemax+1;
    }

    printf("min address (if > 0): %u\n", min_addr);

    unsigned int total_allowed = 0;
    rangemax = arr[0].end;
    i = 1;
    while ( i < nr_ranges ) {
        if ( arr[i].start - 1 > rangemax ) {

//            printf("adding %u ips\n", arr[i].start - rangemax - 1);
            total_allowed += arr[i].start - rangemax - 1;
            rangemax = rangemax < arr[i].end ? arr[i].end : rangemax;
            i++;
        } else {
            rangemax = rangemax < arr[i].end ? arr[i].end : rangemax;
            i++;
        }
    }
    if ( rangemax < MAXNUM ) {
        printf("end adding %u ips\n", MAXNUM - rangemax);
        total_allowed += MAXNUM - rangemax;
    }

    printf("total allowed ips: %u\n", total_allowed);
}
