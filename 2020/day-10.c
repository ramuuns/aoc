#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>
#include "_timer.h"


int compare(const void * a, const void * b) {
    return *(int*)a - *(int*)b;
}

int main() {
    timer_start();
    FILE *fp = fopen("input-10", "r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }

    int nr_adapters = 0;
    char buff[10];
    while ( fgets(buff, 10, fp) ) {
        if ( buff[0] != '\n' ) {
            nr_adapters++;
        }
    }
    fseek(fp, 0, SEEK_SET);
    int adapters[nr_adapters+2];
    int i = 0;
    int max = 0;
    while ( fgets(buff, 10, fp ) ) {
        if ( i < nr_adapters ) {
            sscanf(buff, "%d", &adapters[i++]);
            max = adapters[i-1] > max ? adapters[i-1] : max;
        }
    }
    fclose(fp);
    
    adapters[i++] = max + 3;
    adapters[i] = 0;

    qsort(adapters, nr_adapters+2, sizeof(int), compare);
    int diff_1 = 0;
    int diff_3 = 0;
    int in_skip_block = 0;
    int block_start = 0;

    uint64_t total_options = 1;

    for ( i = 1; i < nr_adapters+2; i++ ) {
        int diff = adapters[i] - adapters[i-1];
        if ( diff == 1 ) {
            diff_1++;
        } else if ( diff == 3 ) {
            diff_3++;
        }
        if ( i < nr_adapters ) {
            int can_skip = adapters[i+1] - adapters[i-1] < 4;
            if ( in_skip_block ) {
                if ( !can_skip ) {
                    int b_diff = adapters[i] - block_start;
                    int b_mul = b_diff == 4 ? 7 : ( b_diff == 3 ? 4 : 2 );
                    total_options *= b_mul;
                    in_skip_block = 0;
                }
            } else {
                if ( can_skip ) {
                    in_skip_block = 1;
                    block_start = adapters[i-1];
                }
            }
        } else {
            if ( in_skip_block && i == nr_adapters ) {
                in_skip_block = 0;
                int b_diff = adapters[i] - block_start;
                int b_mul = b_diff == 4 ? 7 : ( b_diff == 3 ? 4 : 2 );
                total_options *= b_mul;
            }
        }
    }
    unsigned int mul = diff_1 * diff_3;
    printf("%d * %d = %u\n", diff_1, diff_3, mul);
    printf("total options: %"PRIu64"\n", total_options);
    printtime();
}

