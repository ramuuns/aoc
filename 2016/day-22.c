#include <stdio.h>
#include <stdlib.h>

#define WIDTH  31
#define HEIGHT 31

typedef struct _node {
    unsigned char x;
    unsigned char y;
    unsigned int size;
    unsigned int used;
    unsigned int avail;
    unsigned int use_pct;
} Node;

typedef struct _point {
    unsigned char x;
    unsigned char y;
} Point;

typedef struct _basic_state {
    Point hole;
    Point goal_data;
} BasicState;

typedef struct _state {
    Point hole;
    Point goal_data;
    unsigned int moves;
    BasicState previous_moves[255];
} State;

BasicState toBasic(State s) {
    return (BasicState){ .hole = s.hole, .goal_data = s.goal_data };
}

#define HASH_SIZE 0b11111111111111111111

unsigned int hash_state(State s) {
    unsigned int hash = 0;
    hash += s.hole.x;
    hash <<= 5;
    hash += s.hole.y;
    hash <<= 5;
    hash += s.goal_data.x;
    hash <<= 5;
    hash += s.goal_data.y;
    return hash;
}

int heuristic(State s) {
    return (s.goal_data.x + s.goal_data.y) + abs((int)s.goal_data.x - (int)s.hole.x) + abs((int)s.goal_data.y - (int)s.hole.y) + s.moves;
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

int main() {
    char buff[255];
    FILE *fp = fopen("input-22","r");
    if ( !fp ) {
        printf("nope\n");
        exit(1);
    }

    Node nodes[HEIGHT][WIDTH];

    int x;
    int y;
    unsigned int size;
    unsigned int used;
    unsigned int avail;
    unsigned int use_pct;

    unsigned int viable_pairs = 0;    

    while ( fgets(buff, 255, fp) ) {
        if ( buff[0] != '/' ) {
            continue;
        }
        sscanf(buff, "/dev/grid/node-x%d-y%d %uT %uT %uT %u%%", &x, &y, &size, &used, &avail, &use_pct);
        if ( used || avail ) {
            if ( x > 0 ) {
                for ( int xx = 0; xx < x; xx++ ) {
                    for ( int yy = 0; yy < HEIGHT; yy++ ) {
                        viable_pairs += used && nodes[xx][yy].avail > used ? 1 : 0;
                        viable_pairs += avail && nodes[xx][yy].used && avail > nodes[xx][yy].used ? 1 : 0;
                    } 
                }
            }
            for ( int yy = 0; yy < y; yy++ ) {
                viable_pairs += used && nodes[x][yy].avail > used ? 1 : 0;
                viable_pairs += avail && nodes[x][yy].used && avail > nodes[x][yy].used ? 1 : 0;
            }
        }
        nodes[x][y] = (Node){ .x = x, .y = y, .size = size, .used = used, .avail = avail, .use_pct = use_pct };
    }
    fclose(fp);

    printf("valid pairs: %u\n", viable_pairs);

    char c;

    unsigned max_used = 0;
    unsigned min_size = 10000;

    State s = { .hole = (Point){ .x=0, y=0 }, .goal_data = (Point){.x = WIDTH - 1, .y = 0 }, .moves = 0 };

    for ( int y = 0; y < HEIGHT; y++ ) {
        for ( int x = 0; x < WIDTH; x++ ) {
            min_size = min_size < nodes[x][y].size ? min_size : nodes[x][y].size;
            max_used = nodes[x][y].used < 100 && nodes[x][y].used > max_used ? nodes[x][y].used : max_used ;
            c = nodes[x][y].used > 100 ? '#' : (nodes[x][y].used == 0 ? '_' : '.');
            if ( c == '_' ) {
                s.hole.x = (unsigned char)x;
                s.hole.y = (unsigned char)y;
            }
            if ( x == 0 && y == 0 ) {
                printf("(%c)", c);
            } else if ( y == 0 && x == WIDTH -1 ) {
                printf("[G]");
            } else {
                printf(" %c ", c);
            }
        }
        printf("\n");
    }

    char *seen = calloc(HASH_SIZE, sizeof(char));
    
    unsigned int hash = hash_state(s);
    seen[hash] = 1;
    PrioQ* pq = init_PQ();
    pq_insert(pq, s, heuristic(s));
    State newstate;
    while ( has_next(pq) ) {
        s = pop_front(pq);
        if ( s.goal_data.x == 0 && s.goal_data.y == 0 ) {
            break;
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if (     ( s.hole.x > 0 || d > 0)
                  && ( s.hole.x + d < WIDTH )
                  && ( nodes[s.hole.x +d][s.hole.y].used < 100 ) 
               ) {
                newstate = (State){
                    .hole = (Point){ .x = s.hole.x +d, .y = s.hole.y },
                    .goal_data = (Point){ .x = s.goal_data.x, .y =s.goal_data.y },
                    .moves = s.moves + 1 
                };
                if ( newstate.hole.x == s.goal_data.x && newstate.hole.y == s.goal_data.y ) {
                    newstate.goal_data.x = s.hole.x;
                    newstate.goal_data.y = s.hole.y;
                }
                hash = hash_state(newstate);
                if ( !seen[hash] ) {
                    seen[hash] = 1;
                    for ( int i = 0; i < s.moves; i++ ) {
                        newstate.previous_moves[i] = s.previous_moves[i];
                    }
                    newstate.previous_moves[s.moves] = toBasic(s);
                    pq_insert(pq, newstate, heuristic(newstate));
                }
            }
        }
        for ( int d = -1; d < 2; d += 1 ) {
            if (     ( s.hole.y > 0 || d > 0)
                  && ( s.hole.y + d < HEIGHT )
                  && ( nodes[s.hole.x][s.hole.y + d].used < 100 )
               ) {
                newstate = (State){
                    .hole = (Point){ .x = s.hole.x, .y = s.hole.y + d },
                    .goal_data = (Point){ .x = s.goal_data.x, .y =s.goal_data.y },
                    .moves = s.moves + 1
                };
                if ( newstate.hole.x == s.goal_data.x && newstate.hole.y == s.goal_data.y ) {
                    newstate.goal_data.x = s.hole.x;
                    newstate.goal_data.y = s.hole.y;
                }
                hash = hash_state(newstate);
                if ( !seen[hash] ) {
                    seen[hash] = 1;
                    for ( int i = 0; i < s.moves; i++ ) {
                        newstate.previous_moves[i] = s.previous_moves[i];
                    }
                    newstate.previous_moves[s.moves] = toBasic(s);
                    pq_insert(pq, newstate, heuristic(newstate));
                }
            }
        }

    }

    free(seen);
    
    for ( int i = 0; i < s.moves; i++ ) {
        printf("move %d hole xy %u, %u, goal xy: %u %u\n", i+1, s.previous_moves[i].hole.x,s.previous_moves[i].hole.y, s.previous_moves[i].goal_data.x, s.previous_moves[i].goal_data.y );
    }

    printf("moves: %u\n", s.moves);
}
