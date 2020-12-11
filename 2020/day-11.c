#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "_timer.h"

#define OCCUPIED(x) (x == '#')
#define FREE(x) (x == 'L')

void print_grid(char *grid, int rowsize, int rows) {
    for ( int i = 0; i < rowsize * rows; i++ ) {
        if ( i % rowsize == 0 ) {
            printf("\n");
        }
        printf("%c", grid[i]);
    }
    printf("\n\n");
}

int main() {
    timer_start();
    FILE *fp = fopen("input-11","r");
    char buff[100];
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int rowsize = 0;
    int rows = 0;
    while ( fgets(buff, 100, fp) ) {
        if ( buff[0] != '\n' ) {
            rows++;
        }
        if ( rowsize == 0 ) {
            while ( buff[rowsize] != '\n' ) {
                rowsize++;
            }
        }
    }

    char *grid = malloc(sizeof (char) * (rows+2) * (rowsize+2) );
    memset(grid, '.', (rows+2) * (rowsize+2));
    int y = 1;
    fseek(fp, 0, SEEK_SET);
    while ( fgets(buff, 100, fp) ) {
        for ( int x = 0; buff[x] != '\n'; x++ ) {
            *(grid + y *(rowsize+2) + x+1) = buff[x];
        }
        y++;
    }
    //print_grid(grid, rowsize+2, rows+2);
    fclose(fp);
    printtime();
    char *grid_p2 = malloc(sizeof (char) * (rows+2) * (rowsize+2) );
    strncpy(grid_p2, grid, (rows+2) * (rowsize+2));
    char *p_grid = malloc(sizeof (char) * (rows+2) * (rowsize+2) );
    char *fixed_seats = calloc((rows+2) * (rowsize+2), sizeof(char)); 
    strncpy(p_grid, grid, (rows+2) * (rowsize+2));
    int has_changed = 0;
    char **grd = &grid;
    char **pgrid = &p_grid;

    int minx = 1;
    int miny = 1;
    int maxx = rowsize;
    int maxy = rows;

    do {
        char **tmp = grd;
        grd = pgrid;
        pgrid = tmp;

        //print_grid(*pgrid, rowsize+2, rows+2);
//        iter++;
//        if (iter > 6 ) {
//           return 1;
//        }

        int thisminx = maxx;
        int thismaxx = minx;
        int thisminy = maxy;
        int thismaxy = miny;

        has_changed = 0;
        for ( int y = miny; y <= maxy; y++ ) {
            for ( int x = minx; x <= maxx; x++ ) {
                if ( *(fixed_seats +  y*(rowsize+2) + x) ) {
                    continue;
                }
                if ( *((*pgrid) + y*(rowsize+2) + x ) == 'L' ) {
                    *((*grd) + y*(rowsize+2) + x ) = *((*pgrid) + y*(rowsize+2) + x );
                    
                    for ( int yd = -1; yd < 2; yd++ ) {
                        for ( int xd = -1; xd < 2; xd++ ) {
                            if ( yd == 0 && xd == 0 ) {
                                continue;
                            }
                            if ( OCCUPIED( *((*pgrid) + (y+yd)*(rowsize+2) + x +xd ) ) ) {
                                goto occ1;
                            }
                        }
                    }

                    *((*grd) + y*(rowsize+2) + x ) = '#';
                    has_changed = 1;
                    if ( x > thismaxx ) {
                       thismaxx = x;
                    }
                    if ( y > thismaxy ) {
                       thismaxy = y;
                    }
                    if ( x < thisminx ) {
                       thisminx = x;
                    }
                    if ( y < thisminy ) {
                       thisminy = y;
                    }
                    continue;
occ1:
                    *(fixed_seats + + y*(rowsize+2) + x) = 1;
                } else if ( *((*pgrid) + y*(rowsize+2) + x ) == '#' ) {
                    *((*grd) + y*(rowsize+2) + x ) = *((*pgrid) + y*(rowsize+2) + x );
                    int occ_count = 0;
                    for ( int yd = -1; yd < 2; yd++ ) {
                        for ( int xd = -1; xd < 2; xd++ ) {
                            if ( yd == 0 && xd == 0 ) {
                                continue;
                            }
                            if ( OCCUPIED( *((*pgrid) + (y+yd)*(rowsize+2) + x +xd ) ) ) {
                                occ_count++;
                            }
                        }
                    }
                    if ( occ_count >= 4 ) {
                         *((*grd) + y*(rowsize+2) + x ) = 'L';
                        has_changed = 1;
                        if ( x > thismaxx ) {
                           thismaxx = x;
                        }
                        if ( y > thismaxy ) {
                           thismaxy = y;
                        }
                        if ( x < thisminx ) {
                           thisminx = x;
                        }
                        if ( y < thisminy ) {
                           thisminy = y;
                        }
                    } else {
                        *(fixed_seats + + y*(rowsize+2) + x) = 1;
                    }
                }
            }
        }
        minx = thisminx;
        maxx = thismaxx;
        miny = thisminy;
        maxy = thismaxy;
    } while (has_changed);

    int occ_cnt = 0;
    for ( int y = 1; y <= rows; y++ ) {
        for ( int x = 1; x <= rowsize; x++ ) {
            if ( *(*grd + y*(rowsize+2) + x) == '#' ) {
                occ_cnt++;
            }
        }
    }
    printf("occupied seats: %d\n", occ_cnt);
    printtime();
    //strncpy(grid, grid_p2, (rows+2) * (rowsize+2));
    grd = &grid_p2; 

    minx = 1;
    miny = 1;
    maxx = rowsize;
    maxy = rows;
    memset(fixed_seats, 0, (rows+2) * (rowsize+2));

    //for each seat precalculate what the "visible seats" are, so that later we can simply loop over them

    int *spos = calloc( (rows+2) * (rowsize+2) * 8, sizeof(int));
    for ( int y = miny; y <= maxy; y++ ) {
        for ( int x = minx; x <= maxx; x++ ) {
            int pos = y*(rowsize+2) + x;
            int seatpos = 0;
            if ( *((*grd) + pos ) == 'L' ) {
                for ( int yd = -1; yd < 2; yd++ ) {
                    for ( int xd = -1; xd < 2; xd++ ) {
                        if ( yd == 0 && xd == 0 ) {
                            continue;
                        }
                        for ( int j = 1, xx = x + xd*j, yy = y + yd*j; xx > 0 && xx <= rowsize && yy > 0 && yy <= rows; j++, xx = x + xd*j, yy = y + yd*j ) {
                            if ( FREE(*((*grd) + (yy)*(rowsize+2) + xx ) ) ) {
                                *(spos + (pos << 3) + seatpos ) = (yy)*(rowsize+2) + xx;
                                seatpos++;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    printtime();
    do {
        char **tmp = grd;
        grd = pgrid;
        pgrid = tmp;

        //print_grid(*pgrid, rowsize+2, rows+2);
        has_changed = 0;

        int thisminx = maxx;
        int thismaxx = minx;
        int thisminy = maxy;
        int thismaxy = miny;

        for ( int y = miny; y <= maxy; y++ ) {
            for ( int x = minx; x <= maxx; x++ ) {
                int pos = y*(rowsize+2) + x;
                if ( *(fixed_seats + pos) ) {
                    continue;
                }
                if ( *((*pgrid) + pos ) == 'L' ) {
                    for ( int i = 0; i < 8 && *(spos + (pos << 3) + i); i++ ) {
                        if ( OCCUPIED(*(*pgrid + *(spos + (pos << 3) + i))) ) {
                            goto occ2;
                        }
                    }

                    *((*grd) + pos ) = '#';
                    has_changed = 1;
                    if ( x > thismaxx ) {
                       thismaxx = x;
                    }
                    if ( y > thismaxy ) {
                       thismaxy = y;
                    }
                    if ( x < thisminx ) {
                       thisminx = x;
                    }
                    if ( y < thisminy ) {
                       thisminy = y;
                    } 
                    continue;
occ2:               *((*grd) + pos ) = 'L';
                    *(fixed_seats+ pos) = 1;
                    
                } else if ( *((*pgrid) + pos ) == '#' ) {
                    *((*grd) + y*(rowsize+2) + x ) = *((*pgrid) + y*(rowsize+2) + x );
                    int occ_count = 0;
                    for ( int i = 0; i < 8 && *(spos + (pos << 3) + i); i++ ) {
                        if ( OCCUPIED(*(*pgrid + *(spos + (pos << 3) + i))) ) {
                            occ_count++;
                        }
                    }
                    if ( occ_count >= 5 ) {
                        *((*grd) + pos ) = 'L';
                        has_changed = 1;
                        if ( x > thismaxx ) {
                           thismaxx = x;
                        }
                        if ( y > thismaxy ) {
                           thismaxy = y;
                        }
                        if ( x < thisminx ) {
                           thisminx = x;
                        }
                        if ( y < thisminy ) {
                           thisminy = y;
                        }
                    } else {
                        *((*grd) + pos ) = '#';
                        *(fixed_seats+ pos) = 1;
                    }
                }
            }
        }
        minx = thisminx;
        maxx = thismaxx;
        miny = thisminy;
        maxy = thismaxy;
    } while (has_changed);

    occ_cnt = 0;
    for ( int y = 1; y <= rows; y++ ) {
        for ( int x = 1; x <= rowsize; x++ ) {
            if ( *(*grd + y*(rowsize+2) + x) == '#' ) {
                occ_cnt++;
            }
        }
    }
    printf("occupied seats: %d\n", occ_cnt);
    printtime();
}

