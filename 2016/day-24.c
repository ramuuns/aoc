#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _point {
    unsigned char x;
    unsigned char y;
} Point;

typedef struct _state {
    unsigned char x;
    unsigned char y;
    unsigned char keys;
    unsigned int moves;
} State;

#define HASH_SIZE 0b111111111111111111111

unsigned int hash_state(State s) {
    unsigned int hash = 0;
    hash += s.x;
    hash <<= 6;
    hash += s.y;
    hash <<= 7;
    hash += s.keys;
    return hash;
}

typedef struct _deq {
    State s;
    struct _deq* next;
} deq;

deq* push_back(deq* qend, State s) {
    deq* item = malloc(sizeof(deq));
    item->s = s;
    item->next = NULL;
    qend->next = item;
    return item;
}

void cleanup_deq(deq* front) {
    deq* curr = front;
    while ( curr != NULL ) {
        front = curr->next;
        free(curr);
        curr = front;
    }
}

deq* init_deq(State s) {
    deq* item = malloc(sizeof(deq));
    item->s = s;
    item->next = NULL;
    return item;
}


typedef struct _prioq_item {
    int prio;
    deq *start;
    deq *end;
    struct _prioq_item *next;
} PrioQItem;

typedef struct _pq {
    PrioQItem *min_prio;
} PrioQ;

PrioQ* init_PQ() {
    PrioQ *pq = malloc(sizeof(PrioQ));
    pq->min_prio = NULL;
    return pq;
}

PrioQItem* init_PQ_item(int prio) {
    PrioQItem *pqItem = malloc(sizeof(PrioQItem));
    pqItem->prio = prio;
    pqItem->start = NULL;
    pqItem->end = NULL;
    pqItem->next = NULL;
    return pqItem;
}

void pq_insert(PrioQ* pq, State s, int prio){
    if ( pq->min_prio == NULL ) {
        pq->min_prio = init_PQ_item(prio);
    }
    PrioQItem *curr_prio = pq->min_prio;
    while ( curr_prio->prio != prio ) {
        if ( prio < curr_prio->prio ) {
            curr_prio = init_PQ_item(prio);
            curr_prio->next = pq->min_prio;
            pq->min_prio = curr_prio;
            break;
        } else if ( curr_prio->next == NULL ) {
            curr_prio->next = init_PQ_item(prio);
            curr_prio = curr_prio->next;
            break;
        } else if ( curr_prio->next->prio > prio ) {
            PrioQItem *new = init_PQ_item(prio);
            new->next = curr_prio->next;
            curr_prio->next = new;
            curr_prio = new;
            break;
        } else {
            curr_prio = curr_prio->next;
        }
    }
    if ( curr_prio->end == NULL ) {
        curr_prio->end = init_deq(s);
        curr_prio->start = curr_prio->end;
    } else {
        curr_prio->end = push_back(curr_prio->end, s);
    }
}

char has_next(PrioQ* pq) {
    if ( pq->min_prio == NULL ) {
        return 0;
    }
    if ( pq->min_prio->start == NULL ) {
        return 0;
    }
    return 1;
}

State pop_front(PrioQ* pq) {
    deq* curr = pq->min_prio->start;
    State st = curr->s;
    PrioQItem *pqItem = pq->min_prio;
    if ( curr->next != NULL ) {
        pqItem->start = curr->next;
        free(curr);
    } else {
        free(curr);
        pq->min_prio = pq->min_prio->next;
        free(pqItem);
    }
    return st;
}

char char_to_flag(char c) {
    c -= '0';
    char r = 1;
    while ( --c ) {
        r <<= 1;
    }
    return r;
}

int heuristic(State s, Point keypos[9], int num_keys, int part2) {
    int ret = s.moves;
    int keys_left = num_keys;
    int key_left = 0;
    for ( int i = 1; i <= num_keys; i++ ) {
        if ( ( s.keys & (1 << (i-1)) ) == 0 ) {
            keys_left++;
            key_left = i;
        }
    }
    if ( keys_left == 1 ) {
        ret +=  abs((int)s.x - (int)keypos[key_left].x) + abs((int)s.y - (int)keypos[key_left].y);
    }
    if ( part2 && keys_left == 0 ) {
        ret += abs((int)s.x - (int)keypos[0].x) + abs((int)s.y - (int)keypos[0].y);
    }
    return ret;
}

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')

int main() {
    char buff[255];
    FILE *fp = fopen("input-24","r");
    if ( !fp ) {
        printf("nope\n");
        exit(1);
    }

    State s = {.x = 0, .y = 0, .keys = 0, .moves = 0};
    int X, Y = 0;
    while ( fgets(buff, 255, fp) ) {
        Y++;
        X = strlen(buff);
    }

    fseek(fp, 0, SEEK_SET);
    char grid[Y][X];

    int y = 0;
    int numkeys = 0;
    unsigned char keymask = 0;

    Point keypos[9];

    while ( fgets(buff, 255, fp) ) {
        for ( int i = 0; buff[i]; i++ ) {
            grid[y][i] = buff[i];
            if ( buff[i] == '0' ) {
                s.x = i;
                s.y = y;
                keypos[0] = (Point){ .x = i, .y = y };
            } else if ( buff[i] > '0' && buff[i] <= '9' ) {
                numkeys++;
                keymask <<= 1;
                keymask += 1;
                keypos[buff[i] - '0'] = (Point){ .x = i, .y = y }; 
            } 
        }
        y++;
    }
    fclose(fp);

    char *seen = calloc(HASH_SIZE, sizeof(char));
    unsigned int hash = hash_state(s);
    seen[hash] = 1;
    PrioQ* pq = init_PQ();
    pq_insert(pq, s, 0);
    State newstate;
    while ( has_next(pq) ) {
        s = pop_front(pq);
//        printf("moves: %d x:%u y:%u keys "BYTE_TO_BINARY_PATTERN"\n", s.moves, s.x, s.y, BYTE_TO_BINARY(s.keys));
        if ( s.keys == keymask ) {
            break;
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if ( grid[s.y][s.x+d] != '#' ) {
                newstate = (State) { .x = s.x+d, .y=s.y, .moves = s.moves+1, .keys = s.keys };
                if ( grid[s.y][s.x+d] > '0' && grid[s.y][s.x+d] <= '9' ) {
                    newstate.keys = newstate.keys | char_to_flag(grid[s.y][s.x+d]);
                }
                hash = hash_state(newstate);
                if ( !seen[hash] ) {
                    seen[hash] = 1;
                    pq_insert(pq, newstate, heuristic(newstate, keypos, numkeys, 0));
                }
            }
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if ( grid[s.y+d][s.x] != '#' ) {
                newstate = (State) { .x = s.x, .y=s.y+d, .moves = s.moves+1, .keys = s.keys };
                if ( grid[s.y+d][s.x] > '0' && grid[s.y+d][s.x] <= '9' ) {
                    newstate.keys = newstate.keys | char_to_flag(grid[s.y+d][s.x]);
                }
                hash = hash_state(newstate);
                if ( !seen[hash] ) {
                    seen[hash] = 1;
                    pq_insert(pq, newstate, heuristic(newstate, keypos, numkeys, 0));
                }
            }
        }

    }

    free(seen);

    printf("moves: %u\n", s.moves);

    char *seen2 = calloc(HASH_SIZE, sizeof(char));
    s = (State) { .x = keypos[0].x, .y = keypos[0].y, .keys = 0, .moves = 0 };
    hash = hash_state(s);
    seen[hash] = 1;
    PrioQ* pq2 = init_PQ();
    pq_insert(pq2, s, 0);
    while ( has_next(pq2) ) {
        s = pop_front(pq2);
//        printf("moves: %d x:%u y:%u keys "BYTE_TO_BINARY_PATTERN"\n", s.moves, s.x, s.y, BYTE_TO_BINARY(s.keys));
        if ( s.keys == keymask && s.x == keypos[0].x && s.y == keypos[0].y ) {
            break;
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if ( grid[s.y][s.x+d] != '#' ) {
                newstate = (State) { .x = s.x+d, .y=s.y, .moves = s.moves+1, .keys = s.keys };
                if ( grid[s.y][s.x+d] > '0' && grid[s.y][s.x+d] <= '9' ) {
                    newstate.keys = newstate.keys | char_to_flag(grid[s.y][s.x+d]);
                }
                hash = hash_state(newstate);
                if ( !seen2[hash] ) {
                    seen2[hash] = 1;
                    pq_insert(pq2, newstate, heuristic(newstate, keypos, numkeys, 1));
                }
            }
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if ( grid[s.y+d][s.x] != '#' ) {
                newstate = (State) { .x = s.x, .y=s.y+d, .moves = s.moves+1, .keys = s.keys };
                if ( grid[s.y+d][s.x] > '0' && grid[s.y+d][s.x] <= '9' ) {
                    newstate.keys = newstate.keys | char_to_flag(grid[s.y+d][s.x]);
                }
                hash = hash_state(newstate);
                if ( !seen2[hash] ) {
                    seen2[hash] = 1;
                    pq_insert(pq2, newstate, heuristic(newstate, keypos, numkeys, 1));
                }
            }
        }

    }

    free(seen2);

    printf("moves: %u\n", s.moves);
}

