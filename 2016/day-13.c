#include <stdio.h>
#include <stdlib.h>

#define TGT_X 31
#define TGT_Y 39

#define MAGIC 1352


typedef struct _state {
	unsigned short x;
    unsigned short y;
    unsigned int moves;
} State;

typedef struct _deq {
    unsigned short x;
	unsigned short y;
    unsigned int moves;
    struct _deq* next;
} deq;

deq* push_back(deq* qend, unsigned short x, unsigned short y, unsigned int moves) {

    deq* item = malloc(sizeof(deq));
    item->x = x;
	item->y = y;
    item->moves = moves;
    item->next = NULL;
    qend->next = item;
    return item;
}

/*
State q_pop_front(deq* front) {
	State st;
	st.x = front->x;
	st.y = front->y;
	st.moves = front->moves;
	deq* old_front = front;
	front = front->next;
	free(old_front);
	return st;
}
*/

void cleanup_deq(deq* front) {
    deq* curr = front;
    while ( curr != NULL ) {
        front = curr->next;
        free(curr);
        curr = front;
    }
}

deq* init_deq(unsigned short x, unsigned short y, unsigned int moves) {
	deq* item = malloc(sizeof(deq));
    item->x = x;
    item->y = y;
    item->moves = moves;
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
//	PrioQItem *max_prio;
} PrioQ;

int distance(unsigned short x, unsigned short y) {
	return abs(x - TGT_X) + abs(y - TGT_Y);
}

PrioQ* init_PQ() {
	PrioQ *pq = malloc(sizeof(PrioQ));
	pq->min_prio = NULL;
//	pq->max_prio = NULL;
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



void pq_insert(PrioQ* pq, unsigned short x, unsigned short y, unsigned int moves, int prio) {
	if ( pq->min_prio == NULL ) {
		pq->min_prio = init_PQ_item(prio);
//		pq->max_prio = pq->min_prio;		
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
//			pq->max_prio = curr_prio->next;
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
		curr_prio->end = init_deq(x,y,moves);
		curr_prio->start = curr_prio->end;
	} else {
		curr_prio->end = push_back(curr_prio->end, x, y, moves);
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
	State st;
	deq* curr = pq->min_prio->start;
	st.x = curr->x;
	st.y = curr->y;
	st.moves = curr->moves;
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

char is_wall(unsigned short x, unsigned short y) {
	unsigned int result = x*x + 3*x + 2*x*y + y + y*y + MAGIC;
	int bitcnt = 0;
	while ( result ) {
		bitcnt += result & 1;
		result >>= 1;
	}
	return bitcnt & 1;
}

typedef struct _hash {
	char *the_array;
	unsigned int size;
} Hash;

Hash* initHash(unsigned int size) {
	Hash* h = malloc(sizeof(Hash));
	h->the_array = calloc(size, sizeof(char));
	h->size = size;
	return h;
}

void hash_set(Hash* h, unsigned short x, unsigned short y) {
	unsigned int _hash = (x << 16) + y;
	if ( _hash > h->size ) {
		printf("get yourself a bigger hash\n");
		exit(1);
	}
	h->the_array[_hash] = 1;
}

char hash_get(Hash* h, unsigned short x, unsigned short y) {
	unsigned int _hash = (x << 16) + y;
    if ( _hash > h->size ) {
        printf("get yourself a bigger hash\n");
        exit(1);
    }
    return h->the_array[_hash];
}

void print_field(int max_x, int max_y, Hash* seen) {
	int c = 0;
	for (int y = 0; y < max_y; y++ ) {
		for(int x = 0; x < max_x; x++ ) {
			printf("%c", is_wall(x,y) ? '#' : hash_get(seen, x, y) ? 'O': '.');
			if ( hash_get(seen, x, y) ) {
				c++;
			}
		}
		printf("\n");
	}
	printf("in seen hash: %d\n", c);
}

int main() {


	State st = { .x = 1 , .y = 1, .moves = 0 };
	Hash* seen = initHash(0xFFFFFFFF);
	PrioQ* pq = init_PQ();
	pq_insert(pq,st.x, st.y, st.moves, distance(st.x, st.y));
	hash_set(seen, st.x, st.y);
	while ( has_next(pq) ) {
		st = pop_front(pq);
		if ( distance(st.x, st.y) == 0 ) {
			break;
		}
		for ( int d = -1; d < 2; d += 1 ) {
			if ( (d == -1 && st.x > 0) || d > 0 ) {
				if ( !is_wall(st.x + d, st.y) && !hash_get(seen, st.x +d, st.y) ) {
					   hash_set(seen, st.x + d, st.y);
					   pq_insert(pq, st.x + d, st.y, st.moves+1, distance(st.x + d, st.y));
				}
			}
			if ( (d == -1 && st.y > 0) || d > 0 ) {
				if ( !is_wall(st.x , st.y + d) && !hash_get(seen, st.x, st.y +d) ) {
                       hash_set(seen, st.x, st.y+d);
                       pq_insert(pq, st.x, st.y + d, st.moves+1, distance(st.x, st.y + d));
                }
			}
		}
	}

	printf("moves: %d\n", st.moves);

	Hash* seen2 = initHash(0xFFFFFFFF);
	st.x = 1;
	st.y = 1;
	st.moves = 0;
	int seen_pos = 0;
	deq* q = init_deq(st.x, st.y, st.moves);
	hash_set(seen2, st.x, st.y);
	deq* end = q;
	deq* to_free;
	do {
		seen_pos++;
		if ( q->moves < 50 ) {
			for ( int d = -1; d < 2; d += 1 ) {
				if ( (d == -1 && q->x > 0) || d > 0 ) {
					if ( !is_wall(q->x + d, q->y) && !hash_get(seen2, q->x +d, q->y) ) {
						hash_set(seen2, q->x + d, q->y);
						end = push_back(end, q->x + d, q->y, q->moves+1);
					}
				}
				if ( (d == -1 && q->y > 0) || d > 0 ) {
					if ( !is_wall(q->x, q->y + d) && !hash_get(seen2, q->x, q->y + d) ) {
                        hash_set(seen2, q->x, q->y+ d);
                        end = push_back(end, q->x, q->y+d, q->moves+1);
                    }
				}
			}
		}
		to_free = q;
		q = q->next;
		free(to_free);
	} while ( q );

//	print_field(51, 51, seen2);


	printf("total reachable things in 50 moves: %d\n", seen_pos);
}

