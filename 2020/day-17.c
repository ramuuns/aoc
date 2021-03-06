#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

#define TURNS 6

void print_grid(char **grid, int zsize, int xy_size ) {
    int c = 0;
    for ( int z = 0; z < zsize; z++ ) {
        printf("\nz = %d\n", z);
        for ( int y = 0; y < xy_size; y++ ) {
            for ( int x = 0; x < xy_size; x++ ) {
                printf("%c", *(*grid + c) == 1 ? '#' : '.');
                c++;
            }
            printf("\n");
        }
    }
}

void print_4d_grid(char **grid, int zeroidx, int t, int zsize, int xy_size) {
    int cnt = 0;
    for ( int w = zeroidx - t; w <= zeroidx + t; w++ ) {
        for ( int z = zeroidx - t; z <= zeroidx + t; z++ ) {
            printf("\nz = %d, w=%d\n", z, w);
            int c = z*zsize*xy_size*xy_size + w*xy_size*xy_size;
            for ( int y = 0; y < xy_size; y++ ) {
                for ( int x = 0; x < xy_size; x++ ) {
                    printf("%c", *(*grid + c) == 1 ? '#' : '.');
                    cnt += *(*grid + c);
                    c++;
                }
                printf("\n");
            }
        }
    }
    printf("count by printing: %d\n", cnt);
}

int main() {
    timer_start();
    int zsize = TURNS+1;
    int xy_size = TURNS*2+12;
    char *grid =calloc( zsize*xy_size*xy_size, sizeof(char));
    char *grid2 =calloc( zsize*xy_size*xy_size, sizeof(char));
 
    int zsize2 = (TURNS+1)*2+1;
    char *grid3 = calloc( zsize2*zsize2*xy_size*xy_size, sizeof(char));
    char *grid4 = calloc( zsize2*zsize2*xy_size*xy_size, sizeof(char));

    int *planecnt3 = calloc( zsize2*zsize2, sizeof(int));
    int *planecnt4 = calloc( zsize2*zsize2, sizeof(int));

    int *cubecnt3 = calloc( zsize2, sizeof(int));
    int *cubecnt4 = calloc( zsize2, sizeof(int));

    FILE *fp = fopen("input-17","r");
    if ( !fp ) {
        printf("no input\n");
        return 1;
    }
    int x = TURNS+1;
    int y = TURNS+1;
    int zeroidx = zsize2/2;
    int zoffset = zsize2*xy_size*xy_size*zeroidx  + zeroidx*xy_size*xy_size;
    char buff[10];
    int cnt = 0;
    while ( fgets(buff, 10, fp) ) {
        for ( int i = 0; buff[i] != '\n'; i++ ) {
            int c = y*xy_size + x+i;
            *(grid + c) = buff[i] == '#' ? 1 : 0;
            *(grid2 + c) = buff[i] == '#' ? 1 : 0;
            *(grid3 + zoffset + c) = buff[i] == '#' ? 1 : 0;
            *(grid4 + zoffset + c) = buff[i] == '#' ? 1 : 0;
            cnt += buff[i] == '#' ? 1 : 0;
        }
        y++;
    }

    *(planecnt3 + zeroidx*zsize2 + zeroidx) = cnt;
    *(planecnt4 + zeroidx*zsize2 + zeroidx) = cnt;

    *(cubecnt3 + zeroidx) = cnt;
    *(cubecnt4 + zeroidx) = cnt;

    int minxy = x;
    int maxxy = y;

    char **g1 = &grid;
    char **g2 = &grid2;

//    printf("intial grid: \n");
//    print_grid(g1, zsize, xy_size);

    for ( int t = 1; t <= TURNS; t++ ) {
        char **tmp = g1;
        g1 = g2;
        g2 = tmp;
        cnt = 0;
        for ( int z = 0; z <= t; z++ ) {
            for ( y = minxy - t; y < maxxy + t; y++ ) {
                for ( x = minxy - t; x < maxxy + t; x++ ) {
                    int ncnt = 0;
                    for ( int zd = -1; zd < 2; zd++ ) {
                        for ( int yd = -1; yd < 2; yd++ ) {
                            for ( int xd = -1; xd < 2; xd++ ) {
                                if ( zd == 0 && xd == 0 && yd == 0 ) continue;
                                if ( z == 0 ) {
                                    ncnt += *((*g2) + abs(z+zd)*xy_size*xy_size + (y+yd)*xy_size + x+xd);
                                } else {
                                    ncnt += *((*g2) + (z+zd)*xy_size*xy_size +  (y+yd)*xy_size + x+xd);
                                }
                            }
                        }
                    }
                    int c = z*xy_size*xy_size + y * xy_size + x;
                    if ( *((*g2) + c) ) {
                        *((*g1) + c) = ( ncnt == 2 || ncnt == 3 ) ? 1 : 0;
                    } else {
                        *((*g1) + c) = ncnt == 3 ? 1 : 0;
                    }
                    cnt += *((*g1) + c) << ( z > 0 ? 1 : 0);
                }
            }
        }
//        printf("\n\nafter turn %d\n", t);
//        print_grid(g1, zsize, xy_size);
    }

    printf("active count: %d\n", cnt);

    g1 = &grid3;
    g2 = &grid4;

    int **p1 = &planecnt3;
    int **p2 = &planecnt4;

    int **cc1 = &cubecnt3;
    int **cc2 = &cubecnt4;

    int zoff = zsize2*xy_size*xy_size;
    int woff = xy_size*xy_size;
    int yoff = xy_size;

    for ( int t = 1; t <= TURNS; t++ ) {
        char **tmp = g1;
        g1 = g2;
        g2 = tmp;
        int **t2 = p1;
        p1 = p2;
        p2 = t2;
        t2 = cc1;
        cc1 = cc2;
        cc2 = t2;
        cnt = 0;
        for ( int z = zeroidx - t; z <= zeroidx+t; z++ ) {
            *(*(cc1) + z) = 0;
            for ( int w = zeroidx - t; w <= zeroidx+t; w++ ) {
                *(*(p1) + z*zsize2 + w) = 0;
                for ( y = minxy - t; y < maxxy + t; y++ ) {
                    for ( x = minxy - t; x < maxxy + t; x++ ) {
                        int ncnt = 0;
                        for ( int zd = -1; zd < 2; zd++ ) {
                            if ( *(*(cc2) + z+zd) ) {
                            for ( int wd = -1; wd < 2; wd++ ) {
                                if ( *(*(p2) + (z+zd)*zsize2 + w+wd) ) { //only check items in this plane if we know that there's _anyting_ in them
                                for ( int yd = -1; yd < 2; yd++ ) {
                                    for ( int xd = -1; xd < 2; xd++ ) {
                                        if ( zd == 0 && xd == 0 && yd == 0 && wd == 0 ) continue;
                                        ncnt += *((*g2) + (z+zd)*zoff + (w+wd)*woff + (y+yd)*yoff + x+xd);
                                    }
                                }
                                }
                            }
                            }
                        }
                        int c = z*zoff + w*woff + y * yoff + x;
                        if ( *((*g2) + c) ) {
                            *((*g1) + c) = ( ncnt == 2 || ncnt == 3 ) ? 1 : 0;
                        } else {
                            *((*g1) + c) = ncnt == 3 ? 1 : 0;
                        }
                        *(*(p1) + z*zsize2 + w) += *((*g1) + c);
                    }
                }
                cnt += *(*(p1) + z*zsize2 + w);
                *(*(cc1) + z) += *(*(p1) + z*zsize2 + w);
            }
        }
//        printf("\n\nafter turn %d\n", t);
 //       print_4d_grid(g1, zeroidx, t, zsize2, xy_size);
//        printf("active count 4d: %d\n", cnt);
    }

    printf("active count 4d: %d\n", cnt);
    free(grid);
    free(grid2);
    free(grid3);
    free(grid4);
    free(planecnt3);
    free(planecnt4);
    printtime();
}

