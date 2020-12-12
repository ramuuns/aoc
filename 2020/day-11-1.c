#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "_timer.h"


void print_seats(int *grid, int rowsize, int rows) {
    for ( int i = 0; i< (rowsize+2) * (rows+2); i++ ) {
        if ( i % (rowsize+2) == 0 ) {
            printf("\n");
        }
        printf("%c", grid[i] ? ( grid[i] & 1 ? '#' : (grid[i] & 3 ? 'l' : 'L' ) ) : '.');
    }
    printf("\n");
}

void print_coord(int seat, int rowsize) {
    int x = (seat >> 2) % (rowsize + 2);
    int y = (seat >> 2) / (rowsize + 2);
    printf("y:%d, x:%d\n", y,x);
}

/**
 * right, so how does _this_ work?
 *
 * well it's a bit of a BFS, basically first you set the seats that will remain filled, as filled
 * (which would be the ones that have less than $tolerance empty-seated neighbors).
 * then you look at the empty seated neighbors of those seats, and set them to "always empty",
 * because well, they are _empty_ and have a non-empty neighbor, thus can never be filled,
 * then you look for the empty seat neighbors of the seats we just set as empty, and check how many
 * empty seat neighbors _they_ have, and set _those_ to filled if the nr of neighbors is less than tolerance
 * continue doing this until you run out of seats to fill
 */
void fill_seats(int rowsize, int rows, int tolerance, int *grid, int **npos ) {
    int *deq[10000] = { NULL };
    int q_end = 0;
    for ( int i = rowsize+2; i < (rows+1) * (rowsize+2); i++ ) {
        if ( *(grid + i) ) {
            int n_cnt = 0;
//            printf("getting neighbors of: ");
//            print_coord(*(grid+i), rowsize);
            for ( int k = 0; k < 8 && *(npos + (i << 3) + k); k++ ) {
                int is_neg = *(*(npos + (i << 3) + k)) < 0;
                if ( is_neg ) {
                    *(*(npos + (i << 3) + k)) = -(*(*(npos + (i << 3) + k)));
                }

                if ( ! ( *(*(npos + (i << 3) + k)) & 1 ) ) {
//                    print_coord( *(*(npos + (i << 3) + k)), rowsize );
                    n_cnt++;
                }
                if ( is_neg ) {
                     *(*(npos + (i << 3) + k)) = -(*(*(npos + (i << 3) + k)));
                }
            }
            if ( n_cnt < tolerance ) {
                /*
                 * This is a bit of a trick, where to ensure that we don't put the same
                 * seat in the queue twice, we just set it to a negative value, thus if for
                 * whatever reason the same seat would come up twice (not that it can in this loop, but
                 * the next one _would_ have this potential problem) we can ignore it
                 */
                if ( *(grid+i) > 0 ) {
                    deq[q_end++] = grid+i;
                    *(grid+i) = -*(grid+i);
                }
            }
        }
    }
    for ( int i = 0; i < q_end; i++ ) {
        *(deq[i]) = -*(deq[i]);    // since we know that all the seats that we added here were also set to negative we need to reverse that
        *(deq[i]) = *(deq[i]) | 1; // setting a seat to "filled" is simply setting the last bit
    }
//    print_seats(grid, rowsize, rows);
    while ( q_end ) {
        int *empty_list[10000] = { NULL };
        int ecnt = 0;
        for ( int i = 0; i < q_end; i++ ) {
            int addr = *(deq[i]) >> 2;
            for ( int k = 0; k < 8; k++ ) {
                if ( *(npos + (addr << 3) + k) && ( *(*(npos + (addr << 3) + k)) & 3 ) && !(*(*(npos + (addr << 3) + k)) & 1) ) {
                    empty_list[ecnt++] = *(npos + (addr << 3) + k);
                }
            }
        }
        for ( int i =0; i < ecnt; i++ ) {
            *(empty_list[i]) = *(empty_list[i]) >> 2 << 2; // this is one way of setting the last two bits to zero, while keeping the high bits, since we need those to get the neighbors
        }
        q_end = 0;
        for ( int i =0; i < ecnt; i++ ) {
            int addr = *(empty_list[i]) >> 2;
            for ( int k = 0; k < 8; k++ ) {
                if ( *(npos + (addr << 3) + k) &&  *(*(npos + (addr << 3) + k)) > 0 && ( *(*(npos + (addr << 3) + k)) & 3 ) && !(*(*(npos + (addr << 3) + k)) & 1) ) {
                    int n_cnt = 0;
                    int addr2 = *(*(npos + (addr << 3) + k)) >> 2;
                    for ( int kk =0; kk < 8; kk++ ) {
                        if ( *(npos + (addr2 << 3) + kk) ) {
                            int is_neg = *(*(npos + (addr2 << 3) + kk)) < 0;
                            if ( is_neg ) {
                                *(*(npos + (addr2 << 3) + kk)) = -(*(*(npos + (addr2 << 3) + kk)));
                            }
                           
                            if ( ( *(*(npos + (addr2 << 3) + kk)) & 3 ) && !(*(*(npos + (addr2 << 3) + kk)) & 1) ) {
                                n_cnt++;
                            }

                            if ( is_neg ) {
                                *(*(npos + (addr2 << 3) + kk)) = -(*(*(npos + (addr2 << 3) + kk)));
                            }
                        }
                    }
                    if ( n_cnt < tolerance ) {
                        *(*(npos + (addr << 3) + k)) = -*(*(npos + (addr << 3) + k));
                        deq[q_end++] = *(npos + (addr << 3) + k);
                    }
                }
            }
        }
        for ( int i = 0; i < q_end; i++ ) {
            *(deq[i]) = -*(deq[i]);
            *(deq[i]) = *(deq[i]) | 1;
        }
//        print_seats(grid, rowsize, rows);
    }
}

int main(){
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

    int *grid = malloc(sizeof (int) * (rows+2) * (rowsize+2) );
    int *gridp2 = malloc(sizeof (int) * (rows+2) * (rowsize+2) );

    /**
     * so what's in our grids, well instead of just being the characters, we'll encode a bit more information there
     * first of all if it's a 0 then it's floor, and thus we don't care much about it
     * if it's _not_ floor then the last two bits are "seat" and "occupied" so e.g. 10 <- empty seat, 01 <- occupied seat
     * then there's a special 00 <- which is empty seat that will stay empty
     * the higher bits (<<2 ) are however the coordinate itself.
     * this gets handy later, as we'll be getting the neighbors of a given grid item. 
     * so if our grid size is 2x2 then the value 0b1110 would mean an empty seat at coordinate 1,1
     */
    memset(grid, 0, (rows+2) * (rowsize+2));
    memset(gridp2, 0, (rows+2) * (rowsize+2));
    int y = 1;
    fseek(fp, 0, SEEK_SET);
    while ( fgets(buff, 100, fp) ) {
        for ( int x = 0; buff[x] != '\n'; x++ ) {
            if ( buff[x] != '.' ) {
                int addr = y*(rowsize+2) + x+1;
                *(gridp2 + addr) = (addr << 2) + 2;
                *(grid + addr) = (addr << 2) + 2;
            }
        }
        y++;
    }
    fclose(fp);
    /**
     * Here's where we'll be storing our neighbors of each coordinate
     * each coordinate can have no more than 8 neighbors, and we'll be storing references to the
     * actual items in the grid. since we have to store 8 items per item in the grid you can go
     * from grid coordinate to neighbor coordinate in by doing a grid << 2, and then the next 8 items are
     * your neighbors
     */
    int **n_pos = calloc( (rows+2) * (rowsize+2) * 8, sizeof(int*));
    int **n_pos_p2 = calloc( (rows+2) * (rowsize+2) * 8, sizeof(int*));
    for ( int y = 1; y <= rows; y++ ) {
        for ( int x = 1; x <= rowsize; x++ ) {
            int pos = y*(rowsize+2) + x;
            int seatpos_p1 = 0;
            int seatpos_p2 = 0;
            if ( *(grid + pos ) ) {
                for ( int yd = -1; yd < 2; yd++ ) {
                    for ( int xd = -1; xd < 2; xd++ ) {
                        if ( yd == 0 && xd == 0 ) {
                            continue;
                        }
                        for ( int j = 1, xx = x + xd*j, yy = y + yd*j; xx > 0 && xx <= rowsize && yy > 0 && yy <= rows; j++, xx = x + xd*j, yy = y + yd*j ) {
                            if ( *(grid + (yy)*(rowsize+2) + xx) ) {
                                *(n_pos_p2 + (pos << 3) + seatpos_p2 ) = gridp2 + (yy)*(rowsize+2) + xx;
                                seatpos_p2++;
                                if ( j == 1 ) {
                                    *(n_pos + (pos << 3) + seatpos_p1 ) = grid + (yy)*(rowsize+2) + xx;
                                    seatpos_p1++;
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    fill_seats(rowsize, rows, 4, grid, n_pos);
//    printf("\n -------- \n");
    fill_seats(rowsize, rows, 5, gridp2, n_pos_p2);

    int p1_cnt = 0;
    int p2_cnt = 0;
    for ( int i = 0; i < (rows+2) * (rowsize+2); i++ ) {
        if ( *(grid+i) & 1 ) {
            p1_cnt++;
        }
        if ( *(gridp2+i) & 1 ) {
            p2_cnt++;
        }
    }
    printf("part 1 %d\n", p1_cnt);
    printf("part 2 %d\n", p2_cnt);

    printtime();
}
