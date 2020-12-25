#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

void print_grid(char *grid, int minx, int miny, int maxx, int maxy) {
    printf("%d %d\n", minx, miny);
    for ( int y = miny; y <= maxy; y++ ) {
        if ( y % 2 ) printf(" ");
        for ( int x = minx; x<= maxx; x++ ) {
            if ( *(grid+240*y +x ) ) {
                printf("##");
            } else {
                printf("..");
            }
        }
        printf("\n");
    }
}

int main() {
    timer_start();
    FILE *fp = fopen("input-24","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char *grid = calloc(240 * 240, sizeof( char) );

    int c_y = 119; //define the center x and y
    int c_x = 119;
    int x = c_x;
    int y = c_y;

    int min_y = 240;
    int max_y = 0;
    int min_x = 240;
    int max_x = 0;

    char prev = 0;
    char c;
    while ( (c = fgetc(fp)) ) {
        if ( c == EOF ) {
            break;
        }
        if ( c == '\n' ) {
            if ( prev == '\n' ) {
                break;
            }
            //flip tile and reset the coordinates back to center
            //printf("setting %d %d to %d\n", y,x, !grid[y][x]);
            *(grid + y*240 +x) = !*(grid + y * 240 + x);
            if ( x < min_x ) min_x = x;
            if ( x > max_x ) max_x = x;
            if ( y < min_y ) min_y = y;
            if ( y > max_y ) max_y = y;
            x = c_x;
            y = c_y;
        } else {
            switch ( c ) {
                case 'n':
                    y--;
                    break;
                case 's':
                    y++;
                    break;
                case 'w':
                    if ( (prev == 'n' || prev == 's') && !(y&1) ) break;
                    x--;
                    break;
                case 'e':
                    if ( (prev == 'n' || prev == 's') && y&1 ) break;
                    x++;
                    break;
                default:
                    break;
            }
        }
        prev = c;
    }
    char *grid2 = calloc(240*240, sizeof(char));

    int cnt = 0;
    for ( int y = min_y; y <= max_y; y++ ) {
       for ( int x = min_x; x <= max_x; x++ ) {
          cnt += *(grid + y * 240 + x);
          *(grid2 + y * 240 + x) = *(grid + y * 240 + x);
       }
    }

    printf("nr of black tiles: %d\n", cnt);

//    print_grid(grid,min_x, min_y, max_x, max_y);



    char **g1 = &grid;
    char **g2 = &grid2;
    for ( int t = 0; t < 100; t++ ) {
        char **tmp = g1;
        g1 = g2;
        g2 = tmp;
        int new_min_y = 240;
        int new_max_y = 0; 
        int new_min_x = 240;
        int new_max_x = 0;
        if ( min_y == 0 || min_x == 0 || max_y == 238 || max_x == 238 ) {
            printf("getting out of bounds: %d %d %d %d\n", min_y, min_x, max_y, max_x);
            return 1;
        }
        for ( int y = min_y -1; y <= max_y+1; y++ ) {
            for ( int x = min_x - 1; x <= max_x + 1; x++ ) {
                int ncnt = 0;
                ncnt += *(*g2 + y*240 + x - 1) + *(*g2 + y*240 + x + 1);
                ncnt += *(*g2 + (y-1)*240 + x) + *(*g2 + (y-1)*240 + x + ( (y & 1) ? 1 : -1 ));
                ncnt += *(*g2 + (y+1)*240 + x) + *(*g2 + (y+1)*240 + x + ( (y & 1) ? 1 : -1 ));
                if ( *(*g2 + y*240 + x) ) {
                    *(*g1 + y*240 + x) = ncnt > 0 && ncnt < 3;
                } else {
                    *(*g1 + y*240 + x) = ncnt == 2;
                }
                if ( *(*g1 + y*240 + x) ) {
                    if ( x < new_min_x ) new_min_x = x;
                    if ( x > new_max_x ) new_max_x = x;
                    if ( y < new_min_y ) new_min_y = y;
                    if ( y > new_max_y ) new_max_y = y;
                }
            }
        }
        if ( new_min_x < min_x ) min_x = new_min_x;
        if ( new_max_x > max_x ) max_x = new_max_x;
        if ( new_min_y < min_y ) min_y = new_min_y;
        if ( new_max_y > max_y ) max_y = new_max_y;

//        print_grid(*g1, min_x, min_y, max_x, max_y);
    }

    cnt = 0;
    for ( int y = min_y; y <= max_y; y++ ) {
       for ( int x = min_x; x <= max_x; x++ ) {
          cnt += *(*g1 + y * 240 + x);
       }
    }

    printf("nr of black tiles: %d\n", cnt);

    printtime();
}
