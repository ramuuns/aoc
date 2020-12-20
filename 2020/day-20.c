#include <stdio.h>
#include "_timer.h"

#define TILES_PER_ROW 12
#define IMAGE_SIZE 96

typedef struct _tile {
    int id;
    int ncnt;
    int seen;
    int n_idx;
    int n;
    int s_idx;
    int s;
    int w_idx;
    int w;
    int e_idx;
    int e;
    char image[8][8];
} tile_t;

int reverse_bits(int n) {
    int r = 0;
    for ( int i = 0; i < 10; i++ ) {
        r <<= 1;
        r |= (n >> i) & 1;
    }
    return r;
}

void rotate_tile (tile_t *tile) {
    int tmp = tile->n;
    tile->n = reverse_bits(tile->w);
    tile->w = tile->s;
    tile->s = reverse_bits(tile->e);
    tile->e = tmp;
    char t;
    for ( int i = 0; i < 4; i++ ) {
        for ( int j = i; j < 8 - i - 1; j++ ) {
            t = tile->image[i][j];
            tile->image[i][j] = tile->image[8 - 1 - j][i];
            tile->image[8 - 1 - j][i] = tile->image[8 - 1 - i][8 - 1 - j];
            tile->image[8 - 1 - i][8 - 1 - j] = tile->image[j][8 - 1 - i];
            tile->image[j][8 - 1 - i] = t;
        }
    }
}

void flip_tile(tile_t *tile) {
    int tmp = tile->n;
    tile->n = tile->s;
    tile->s = tmp;
    tile->e = reverse_bits(tile->e);
    tile->w = reverse_bits(tile->w);
    for ( int y = 0; y<4; y++ ) {
        for ( int x = 0; x<8; x++ ) {
            char t = tile->image[y][x];
            tile->image[y][x] = tile->image[7-y][x];
            tile->image[7-y][x] = t;
        }
    }
}

void rotate_image(char grid[IMAGE_SIZE][IMAGE_SIZE]) {
    char t;
    for ( int i = 0; i < IMAGE_SIZE / 2; i++ ) {
        for ( int j = i; j < IMAGE_SIZE - i - 1; j++ ) {
            t = grid[i][j];
            grid[i][j] = grid[IMAGE_SIZE - 1 - j][i];
            grid[IMAGE_SIZE - 1 - j][i] = grid[IMAGE_SIZE - 1 - i][IMAGE_SIZE - 1 - j];
            grid[IMAGE_SIZE - 1 - i][IMAGE_SIZE - 1 - j] = grid[j][IMAGE_SIZE - 1 - i];
            grid[j][IMAGE_SIZE - 1 - i] = t;
        }
    }
}

void flip_image(char grid[IMAGE_SIZE][IMAGE_SIZE]) {
    for ( int y = 0; y< IMAGE_SIZE/2; y++ ) {
        for ( int x = 0; x< IMAGE_SIZE; x++ ) {
            char t = grid[y][x];
            grid[y][x] = grid[IMAGE_SIZE -1 -y][x];
            grid[IMAGE_SIZE - 1 -y][x] = t;
        }
    }
}

void print_image( char grid[IMAGE_SIZE][IMAGE_SIZE]) {
    for ( int y = 0; y< IMAGE_SIZE; y++ ) {
        for ( int x = 0; x < IMAGE_SIZE; x++ ) {
            printf("%c", grid[y][x] ? '#' : '.' );
        }
        printf("\n");
    }

}

#define MONSTER_W 20
#define MONSTER_H 3

int contains_monster(char grid[IMAGE_SIZE][IMAGE_SIZE]) {
    int ret = 0;
    int has_monster = 0;
    for ( int y = 0; y < IMAGE_SIZE; y++ ) {
        for ( int x = 0; x < IMAGE_SIZE; x++ ) {
            if ( ( y < IMAGE_SIZE - MONSTER_H && x < IMAGE_SIZE - MONSTER_W ) && ( grid[y][x + 18]
              && grid[y+1][x] && grid[y+1][x+5] && grid[y+1][x+6] && grid[y+1][x+11] && grid[y+1][x+12] && grid[y+1][x+17] && grid[y+1][x+18] && grid[y+1][x+19]
              && grid[y+2][x+1] && grid[y+2][x+4] && grid[y+2][x+7] && grid[y+2][x+10] && grid[y+2][x+13] && grid[y+2][x+16] ) ) {
                has_monster = 1;
                ret -= 15;
            }
            ret += grid[y][x];
        }
    }
    if ( !has_monster ) {
        return 0;
    }
    return ret;
}

int main() {
    timer_start();
    FILE *fp = fopen("input-20", "r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int b_map[1024] = { 0 };
    int num_tiles = 0;
    tile_t tiles[144] = { {.id = 0, .ncnt = 0, .seen = 0, .n = 0, .s = 0, .w = 0, .e = 0} };
    int tiles_to_idx[1024][2];
    for ( int i = 0; i < 1024; i ++ ) {
        tiles_to_idx[i][0] = -1;
        tiles_to_idx[i][1] = -1;
    }
    char buff[20];
    int n = 0;
    while ( fgets(buff, 20, fp) ) {
        if (buff[0] == '\n') {
            continue;
        }
        if ( buff[0] == 'T' ) {
            num_tiles++;
            tiles[num_tiles-1].s_idx = -1;
            tiles[num_tiles-1].n_idx = -1;
            tiles[num_tiles-1].e_idx = -1;
            tiles[num_tiles-1].w_idx = -1;
            sscanf(buff, "Tile %d:", &tiles[num_tiles-1].id);
            n = 0;
        } else {
            tiles[num_tiles-1].w <<= 1;
            tiles[num_tiles-1].e <<= 1;
            tiles[num_tiles-1].w |= buff[0] == '#';
            tiles[num_tiles-1].e |= buff[9] == '#';
            if ( n == 0 ) {
                for ( int i = 0; i < 10; i++ ) {
                    tiles[num_tiles-1].n <<= 1;
                    tiles[num_tiles-1].n |= buff[i] == '#';
                }
            } else if ( n == 9 ) {
                for ( int i = 0; i < 10; i++ ) {
                    tiles[num_tiles-1].s <<= 1;
                    tiles[num_tiles-1].s |= buff[i] == '#';
                }
                b_map[tiles[num_tiles-1].w] = reverse_bits(tiles[num_tiles-1].w);
                b_map[tiles[num_tiles-1].e] = reverse_bits(tiles[num_tiles-1].e);
                b_map[tiles[num_tiles-1].n] = reverse_bits(tiles[num_tiles-1].n);
                b_map[tiles[num_tiles-1].s] = reverse_bits(tiles[num_tiles-1].s);

                b_map[reverse_bits( tiles[num_tiles-1].w) ] = tiles[num_tiles-1].w;
                b_map[reverse_bits( tiles[num_tiles-1].e) ] = tiles[num_tiles-1].e;
                b_map[reverse_bits( tiles[num_tiles-1].n) ] = tiles[num_tiles-1].n;
                b_map[reverse_bits( tiles[num_tiles-1].s) ] = tiles[num_tiles-1].s;
                if ( tiles_to_idx[tiles[num_tiles-1].w][0] != -1 ) {
                    if ( tiles_to_idx[tiles[num_tiles-1].w][1] != -1 ) {
                        printf("seems like this border shows up more than twice o_O\n");
                        printf("this id: %d, previous ids %d and %d\n", tiles[num_tiles-1].id, tiles[ tiles_to_idx[tiles[num_tiles-1].w][0] ].id, tiles[ tiles_to_idx[tiles[num_tiles-1].w][1] ].id);
                        return 1;
                    } 
                    tiles_to_idx[tiles[num_tiles-1].w][1] = num_tiles-1;
                } else {
                    tiles_to_idx[tiles[num_tiles-1].w][0] = num_tiles-1;
                }

                if ( tiles_to_idx[tiles[num_tiles-1].e][0] != -1 ) {
                    if ( tiles_to_idx[tiles[num_tiles-1].e][1] != -1 ) {
                        printf("seems like this border shows up more than twice o_O\n");
                        printf("this id: %d, previous ids %d and %d\n", tiles[num_tiles-1].id, tiles[ tiles_to_idx[tiles[num_tiles-1].e][0] ].id, tiles[ tiles_to_idx[tiles[num_tiles-1].e][1] ].id);
                        return 1;
                    } 
                    tiles_to_idx[tiles[num_tiles-1].e][1] = num_tiles-1;
                } else {
                    tiles_to_idx[tiles[num_tiles-1].e][0] = num_tiles-1;
                }

                if ( tiles_to_idx[tiles[num_tiles-1].s][0] != -1 ) {
                    if ( tiles_to_idx[tiles[num_tiles-1].s][1] != -1 ) {
                        printf("seems like this border shows up more than twice o_O\n");
                        printf("this id: %d, previous ids %d and %d\n", tiles[num_tiles-1].id, tiles[ tiles_to_idx[tiles[num_tiles-1].s][0] ].id, tiles[ tiles_to_idx[tiles[num_tiles-1].s][1] ].id);
                        return 1;
                    }
                    tiles_to_idx[tiles[num_tiles-1].s][1] = num_tiles-1;
                } else {
                    tiles_to_idx[tiles[num_tiles-1].s][0] = num_tiles-1;
                }

                if ( tiles_to_idx[tiles[num_tiles-1].n][0] != -1 ) {
                    if ( tiles_to_idx[tiles[num_tiles-1].n][1] != -1 ) {
                        printf("seems like this border shows up more than twice o_O\n");
                        printf("this id: %d, previous ids %d and %d\n", tiles[num_tiles-1].id, tiles[ tiles_to_idx[tiles[num_tiles-1].n][0] ].id, tiles[ tiles_to_idx[tiles[num_tiles-1].n][1] ].id);
                        return 1;
                    }
                    tiles_to_idx[tiles[num_tiles-1].n][1] = num_tiles-1;
                } else {
                    tiles_to_idx[tiles[num_tiles-1].n][0] = num_tiles-1;
                }
            } else {
                for ( int i = 1; i < 9; i++ ) {
                    tiles[num_tiles-1].image[n-1][i-1] = buff[i] == '#';
                }
            }
            n++;
        }
    }

    int deq[144];
    int qst = 0;
    int qend = 0;
    deq[qend++] = 0;
    tiles[0].seen = 1;
    while ( qst != qend ) {
        int tile_idx = deq[qst++];
        int fit1 = 1;
        int fit2 = 1;
        int fit3 = 1;
        int fit4 = 1;
start_s:
        if ( fit1 && tiles_to_idx[ tiles[tile_idx].s ][0] >= 0 && tiles_to_idx[ tiles[tile_idx].s ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].s_idx = tiles_to_idx[ tiles[tile_idx].s ][0];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].s ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].s ][0] ].n != tiles[tile_idx].s ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].s ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].s ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    //well fuck, this one actually doesn't fit
                    fit1 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].s_idx = -1;
                    goto start_s;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].s ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].s ][0];
            }
        } else if ( fit2 && tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].s ] ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].s_idx = tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] ].n != tiles[tile_idx].s ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit2 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].s_idx = -1;
                    goto start_s;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].s] ][0];
            }
        } else if ( fit3 && tiles_to_idx[ tiles[tile_idx].s ][1] >= 0 && tiles_to_idx[ tiles[tile_idx].s ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].s_idx = tiles_to_idx[ tiles[tile_idx].s ][1];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].s ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].s ][1] ].n != tiles[tile_idx].s ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].s ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].s ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit3 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].s_idx = -1;
                    goto start_s;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].s ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].s ][1];
            }
        } else if ( fit4 && tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].s ] ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].s_idx = tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] ].n != tiles[tile_idx].s ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit4 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].s_idx = -1;
                    goto start_s;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].s ] ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].s] ][1];
            }
        }

        fit1 = 1;
        fit2 = 1;
        fit3 = 1;
        fit4 = 1;
start_n:
        if ( fit1 && tiles_to_idx[ tiles[tile_idx].n ][0] >= 0 && tiles_to_idx[ tiles[tile_idx].n ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].n_idx = tiles_to_idx[ tiles[tile_idx].n ][0];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].n ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].n ][0] ].s != tiles[tile_idx].n ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].n ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].n ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit1 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].n_idx = -1;
                    goto start_n;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].n ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].n ][0];
            }
        } else if ( fit2 && tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].n ] ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].n_idx = tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] ].s != tiles[tile_idx].n ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit2 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].n_idx = -1;
                    goto start_n;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].n] ][0];
            }
        } else if ( fit3 && tiles_to_idx[ tiles[tile_idx].n ][1] >= 0 && tiles_to_idx[ tiles[tile_idx].n ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].n_idx = tiles_to_idx[ tiles[tile_idx].n ][1];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].n ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].n ][1] ].s != tiles[tile_idx].n ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].n ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].n ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit3 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].n_idx = -1;
                    goto start_n;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].n ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].n ][1];
            }
        } else if ( fit4 && tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].n ] ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].n_idx = tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] ].s != tiles[tile_idx].n ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit4 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].n_idx = -1;
                    goto start_n;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].n ] ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].n] ][1];
            }
        }

        fit1 = 1;
        fit2 = 1;
        fit3 = 1;
        fit4 = 1;
start_e:
        if ( fit1 && tiles_to_idx[ tiles[tile_idx].e ][0] >= 0 && tiles_to_idx[ tiles[tile_idx].e ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].e_idx = tiles_to_idx[ tiles[tile_idx].e ][0];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].e ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].e ][0] ].w != tiles[tile_idx].e ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].e ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].e ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit1 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].e_idx = -1;
                    goto start_e;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].e ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].e ][0];
            }
        } else if ( fit2 && tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].e ] ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].e_idx = tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] ].w != tiles[tile_idx].e ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit2 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].e_idx = -1;
                    goto start_e;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].e] ][0];
            }
        } else if ( fit3 && tiles_to_idx[ tiles[tile_idx].e ][1] >= 0 && tiles_to_idx[ tiles[tile_idx].e ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].e_idx = tiles_to_idx[ tiles[tile_idx].e ][1];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].e ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].e ][1] ].w != tiles[tile_idx].e ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].e ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].e ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit3 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].e_idx = -1;
                    goto start_e;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].e ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].e ][1];
            }
        } else if ( fit4 && tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].e ] ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].e_idx = tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] ].w != tiles[tile_idx].e ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit4 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].e_idx = -1;
                    goto start_e;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].e ] ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].e] ][1];
            }
        }

        fit1 = 1;
        fit2 = 1;
        fit3 = 1;
        fit4 = 1;
start_w:
        if ( fit1 && tiles_to_idx[ tiles[tile_idx].w ][0] >= 0 && tiles_to_idx[ tiles[tile_idx].w ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].w_idx = tiles_to_idx[ tiles[tile_idx].w ][0];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].w ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].w ][0] ].e != tiles[tile_idx].w ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].w ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].w ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit1 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].w_idx = -1;
                    goto start_w;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].w ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].w ][0];
            }
        } else if ( fit2 && tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].w ] ][0] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].w_idx = tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] ].e != tiles[tile_idx].w ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] ]);
                    }
                }
                if ( n == 8 ) {
                    fit2 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].w_idx = -1;
                    goto start_w;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][0] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].w] ][0];
            }
        } else if ( fit3 && tiles_to_idx[ tiles[tile_idx].w ][1] >= 0 && tiles_to_idx[ tiles[tile_idx].w ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
            tiles[tile_idx].w_idx = tiles_to_idx[ tiles[tile_idx].w ][1];
            if ( tiles[ tiles_to_idx[ tiles[tile_idx].w ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ tiles[tile_idx].w ][1] ].e != tiles[tile_idx].w ) {
                    rotate_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].w ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ tiles[tile_idx].w ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit3 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].w_idx = -1;
                    goto start_w;
                }
                tiles[ tiles_to_idx[ tiles[tile_idx].w ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ tiles[tile_idx].w ][1];
            }
        } else if ( fit4 && tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] >= 0 && tiles_to_idx[ b_map [ tiles[tile_idx].w ] ][1] != tile_idx ) {
            tiles[tile_idx].ncnt++;
             tiles[tile_idx].w_idx = tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1];
            if ( tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] ].seen == 0 ) {
                n = 0;
                while ( n < 8 && tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] ].e != tiles[tile_idx].w ) {
                    rotate_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] ]);
                    n++;
                    if ( n == 4 ) {
                        flip_tile(&tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] ]);
                    }
                }
                if ( n == 8 ) {
                    fit4 = 0;
                    tiles[tile_idx].ncnt--;
                    tiles[tile_idx].w_idx = -1;
                    goto start_w;
                }
                tiles[ tiles_to_idx[ b_map[ tiles[tile_idx].w ] ][1] ].seen = 1;
                deq[qend++] = tiles_to_idx[ b_map[ tiles[tile_idx].w] ][1];
            }
        }

//        printf("tile id %d (%d) attached %d neighbors (n: %d, s:%d, e:%d w: %d)\n", tiles[tile_idx].id, tile_idx, tiles[tile_idx].ncnt, tiles[tile_idx].n_idx,  tiles[tile_idx].s_idx,  tiles[tile_idx].e_idx, tiles[tile_idx].w_idx);
    }

    unsigned long mul = 1;
    int nw_corner = -1;
    for ( int i = 0; i < num_tiles; i++ ) {
        if ( tiles[i].ncnt == 2 ) {
            mul *= tiles[i].id;
            if ( tiles[i].n_idx == -1 && tiles[i].w_idx == -1 ) {
                nw_corner = i;
            }
        }
    }
    printf("mul: %lu\n", mul);

    char image[IMAGE_SIZE][IMAGE_SIZE];
    int this_row = nw_corner;
    for ( int big_y = 0; big_y < TILES_PER_ROW; big_y++ ) {
       int this_col = this_row;
       for ( int big_x = 0; big_x < TILES_PER_ROW; big_x++ ) {
            for ( int y = 0; y < 8; y++ ) {
                for ( int x = 0; x < 8; x++ ) {
                    image[big_y*8 + y][big_x*8 + x] = tiles[this_col].image[y][x];
                }
            }
            this_col = tiles[this_col].e_idx;
       }
       this_row = tiles[this_row].s_idx;
//    print_image(image);
    }


    int tile_cnt = 0;
    n = 0;
    do {
        tile_cnt = contains_monster(image);
        if ( ! tile_cnt ) {
            rotate_image(image);
            n++;
            if ( n == 4 ) {
                flip_image(image);
            }
        }
    } while ( !tile_cnt && n < 8 );

    printf("nr tiles: %d\n", tile_cnt); 

    printtime();
}
