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
    char *p_grid = malloc(sizeof (char) * (rows+2) * (rowsize+2) );
    char *p_grid_p2 = malloc(sizeof (char) * (rows+2) * (rowsize+2) );
    strncpy(grid_p2, grid, (rows+2) * (rowsize+2));
    strncpy(p_grid_p2, grid, (rows+2) * (rowsize+2));
    strncpy(p_grid, grid, (rows+2) * (rowsize+2));
    char *fixed_seats = calloc((rows+2) * (rowsize+2), sizeof(char)); 
    char *fixed_seats_p2 = calloc((rows+2) * (rowsize+2), sizeof(char)); 
    int has_changed_p1 = 0;
    int has_changed_p2 = 0;
    int p1_done = 0;
    int p2_done = 0;
    char **grdp1 = &grid;
    char **pgridp1 = &p_grid;
    char **grdp2 = &grid_p2;
    char **pgridp2 = &p_grid_p2;

    int minx = 1;
    int miny = 1;
    int maxx = rowsize;
    int maxy = rows;

    int *spos = calloc( (rows+2) * (rowsize+2) * 8, sizeof(int));
    for ( int y = miny; y <= maxy; y++ ) {
        for ( int x = minx; x <= maxx; x++ ) {
            int pos = y*(rowsize+2) + x;
            int seatpos = 0;
            if ( *((*grdp1) + pos ) == 'L' ) {
                for ( int yd = -1; yd < 2; yd++ ) {
                    for ( int xd = -1; xd < 2; xd++ ) {
                        if ( yd == 0 && xd == 0 ) {
                            continue;
                        }
                        for ( int j = 1, xx = x + xd*j, yy = y + yd*j; xx > 0 && xx <= rowsize && yy > 0 && yy <= rows; j++, xx = x + xd*j, yy = y + yd*j ) {
                            if ( FREE(*((*grdp1) + (yy)*(rowsize+2) + xx ) ) ) {
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

    do {
        char **tmp;
        if ( !p1_done ) {
            tmp = grdp1;
            grdp1 = pgridp1;
            pgridp1 = tmp;
        }

        if ( !p2_done ) {
            tmp = grdp2;
            grdp2 = pgridp2;
            pgridp2 = tmp;
        }

//        print_grid(*pgridp2, rowsize+2, rows+2);
//        iter++;
//        if (iter > 6 ) {
//           return 1;
//        }

        int thisminx = maxx;
        int thismaxx = minx;
        int thisminy = maxy;
        int thismaxy = miny;

        if ( !p1_done ) {
            has_changed_p1 = 0;
        }
        if ( !p2_done ) {
            has_changed_p2 = 0;
        }
        for ( int y = miny; y <= maxy; y++ ) {
            for ( int x = minx; x <= maxx; x++ ) {
                int pos = y*(rowsize+2) + x;
                if ( !p1_done ) {
                    if ( *(fixed_seats + pos ) ) {
                        goto p2;
                    }
                    if ( *(*pgridp1 + pos) == 'L' ) {
                        *(*grdp1 + pos ) = *(*pgridp1 + pos);
                        
                        for ( int yd = -1; yd < 2; yd++ ) {
                            for ( int xd = -1; xd < 2; xd++ ) {
                                if ( yd == 0 && xd == 0 ) {
                                    continue;
                                }
                                if ( OCCUPIED( *((*pgridp1) + (y+yd)*(rowsize+2) + x +xd ) ) ) {
                                    goto occ1;
                                }
                            }
                        }

                        *(*grdp1 + pos) = '#';
                        has_changed_p1 = 1;
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
                        goto p2;
occ1:
                        *(fixed_seats + pos ) = 1;
                    } else if ( *(*pgridp1 + pos) == '#' ) {
                        *(*grdp1 + pos ) = *(*pgridp1 + pos);
                        int occ_count = 0;
                        for ( int yd = -1; yd < 2; yd++ ) {
                            for ( int xd = -1; xd < 2; xd++ ) {
                                if ( yd == 0 && xd == 0 ) {
                                    continue;
                                }
                                if ( OCCUPIED( *((*pgridp1) + (y+yd)*(rowsize+2) + x +xd ) ) ) {
                                    occ_count++;
                                }
                            }
                        }
                        if ( occ_count >= 4 ) {
                            *(*grdp1 + pos) = 'L';
                            has_changed_p1 = 1;
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
                            *(fixed_seats +  pos) = 1;
                        }
                    }
                }
p2:
                if ( !p2_done ) {
                    if ( *(fixed_seats_p2 + pos) ) {
                        continue;
                    }
                    if ( *((*pgridp2) + pos ) == 'L' ) {
                        for ( int i = 0; i < 8 && *(spos + (pos << 3) + i); i++ ) {
                            if ( OCCUPIED(*(*pgridp2 + *(spos + (pos << 3) + i))) ) {
                                goto occ2;
                            }
                        }
                        *((*grdp2) + pos ) = '#';
                        has_changed_p2 = 1;
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
occ2:                   *((*grdp2) + pos ) = 'L';
                        *(fixed_seats_p2 + pos) = 1;

                    } else if ( *((*pgridp2) + pos ) == '#' ) {
                        int occ_count = 0;
                        for ( int i = 0; i < 8 && *(spos + (pos << 3) + i); i++ ) {
                            if ( OCCUPIED(*(*pgridp2 + *(spos + (pos << 3) + i))) ) {
                                occ_count++;
                            }
                        }
                        if ( occ_count >= 5 ) {
                            *((*grdp2) + pos ) = 'L';
                            has_changed_p2 = 1;
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
                            *((*grdp2) + pos ) = '#';
                            *(fixed_seats_p2+ pos) = 1;
                        }
                    }
                }
            }
        }
        minx = thisminx;
        maxx = thismaxx;
        miny = thisminy;
        maxy = thismaxy;
        p1_done = p1_done || !has_changed_p1;
        p2_done = p2_done || !has_changed_p2;
    } while (!p1_done || !p2_done);

    int occ_cnt_p1 = 0;
    int occ_cnt_p2 = 0;
    for ( int y = 1; y <= rows; y++ ) {
        for ( int x = 1; x <= rowsize; x++ ) {
            if ( *(*grdp1 + y*(rowsize+2) + x) == '#' ) {
                occ_cnt_p1++;
            }
            if ( *(*grdp2 + y*(rowsize+2) + x) == '#' ) {
                occ_cnt_p2++;
            }
        }
    }
    printf("occupied seats p1: %d\n", occ_cnt_p1);
    printf("occupied seats p2: %d\n", occ_cnt_p2);

    printtime();

}

