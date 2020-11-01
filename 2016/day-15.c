#include <stdio.h>
#include <stdlib.h>

typedef struct _disc {
    int mod;
    int offset;
    int idx;
} disc;

int main() {
    int num_discs = 0;
    FILE *fp = fopen("input-15", "r");
    if ( fp == NULL ) {
        printf("couldn't open file\n");
        exit(1);
    }
    char buffer[255];
    while ( fgets(buffer, 255, fp) ) {
        num_discs++;
    }
    fseek(fp, 0, SEEK_SET);
    disc discs[num_discs];
    int idx;
    int positions;
    int offset;
    while ( fgets(buffer, 255, fp) ) {
        sscanf(buffer, "Disc #%d has %d positions; at time=0, it is at position %d.", &idx, &positions, &offset);
        discs[idx-1].mod = positions;
        discs[idx-1].offset = offset;
        discs[idx-1].idx = idx;
    }
    fclose(fp);
    int t = 0;
    int mod_sum = 0;
    do {
        mod_sum = 0;
        for ( int i = 0; i < num_discs; i++ ) {
            mod_sum += (discs[i].idx + discs[i].offset + t) % discs[i].mod;
            if ( mod_sum > 0 ) {
                break;
            }
        }
        if ( mod_sum > 0 ) {
            t++;
        }
    } while ( mod_sum );
    printf("good start time: %d\n", t);
    disc magic_disc;
    magic_disc.idx = num_discs + 1;
    magic_disc.offset = 0;
    magic_disc.mod = 11;

   t = 0;
   do {
        mod_sum = (magic_disc.idx + t) % magic_disc.mod;
        if ( mod_sum > 0 ) {
            t++;
            continue;
        }
        for ( int i = 0; i < num_discs; i++ ) {
            mod_sum += (discs[i].idx + discs[i].offset + t) % discs[i].mod;
            if ( mod_sum > 0 ) {
                break;
            }
        }
        if ( mod_sum > 0 ) {
            t++;
        }
    } while ( mod_sum );
    printf("good start time part 2: %d\n", t);

}
