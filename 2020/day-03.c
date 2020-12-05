#include <stdio.h>
#include "_timer.h"

typedef struct _slope {
    int xdiff;
    int ydiff;
    int x;
    int y;
    int trees;
} slope;

int main() {
    timer_start();
    FILE *fp = fopen("input-03","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];

    slope slopes[5] = {
        { .xdiff = 1, .ydiff = 1, .x = 0, .y = 0, .trees = 0  },
        { .xdiff = 3, .ydiff = 1, .x = 0, .y = 0, .trees = 0  },
        { .xdiff = 5, .ydiff = 1, .x = 0, .y = 0, .trees = 0  },
        { .xdiff = 7, .ydiff = 1, .x = 0, .y = 0, .trees = 0  },
        { .xdiff = 1, .ydiff = 2, .x = 0, .y = 0, .trees = 0  },
    };

    int width = 0;
    int y = 0;
    while ( fgets(buff, 255, fp) ) {
        if ( width == 0 ) {
            for ( int i = 0; buff[i] == '.' || buff[i] == '#'; i++ ) {
                width++;
            }
        }
        for ( int i = 0; i < 5; i++ ) {
            if ( slopes[i].y == y ) {
                slopes[i].trees += buff[slopes[i].x %width] == '#' ? 1 : 0;
                slopes[i].x += slopes[i].xdiff;
                slopes[i].y += slopes[i].ydiff;
            }
        }
        y++;
    }
    fclose(fp);
    printf("num trees: %d\n", slopes[1].trees);
    unsigned int mul = 1;
    for ( int i = 0; i < 5; i++ ) {
        mul *= slopes[i].trees;
    }
    printf("multiplied tres: %u\n", mul);
    printtime();
}
