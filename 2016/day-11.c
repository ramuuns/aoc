#include <stdio.h>
#include <stdlib.h>
//#include <inttypes.h>

#define PART2
#ifdef PART2

#define NUM_KINDS 7
#define NUM_ITEMS 14
#define HASH_SIZE 0x3FFFFFFF 

#else

#define NUM_KINDS 5
#define NUM_ITEMS 10
#define HASH_SIZE 0x3FFFFF

#endif

#define BYTE_TO_BINARY_PATTERN "%c%c %c%c %c%c %c%c "
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 


char can_move(char _floor[NUM_ITEMS], int tgt) {
    if ( tgt < NUM_KINDS ) {
        return 1;
    }
    if ( _floor[tgt - NUM_KINDS] ) {
        for ( int i = NUM_KINDS; i < NUM_ITEMS; i ++ ) {
            if ( i != tgt && _floor[i] ) {
                return 0;
            }
        }
    }
    return 1;
}

char floor_is_ok(char _floor[NUM_ITEMS]) {
	int has_chips = 0;
	int has_generators = 0;
	for ( int i = 0; i < NUM_KINDS; i++ ) {
		has_chips = has_chips || _floor[i];
		has_generators = has_generators || _floor[i+NUM_KINDS];
	}
	if ( has_chips && !has_generators ) {
		return 1;
	}
	if ( has_generators && !has_chips ) {
		return 1;
	}
	for ( int i = 0; i < NUM_KINDS; i++ ) {
		if ( _floor[i] && !_floor[i+NUM_KINDS] ) {
			return 0;
		}
	}
	return 1;
}

unsigned int hash_state(char floors[4][NUM_ITEMS], int elevator) {
    unsigned int state = 0;
	for ( int j = 0; j < NUM_ITEMS; j++ ) {
		for ( int i = 0; i < 4; i++ ) {
			if ( floors[i][j] ) {
				state += i;
				state <<= 2;
			}
        }
    }
	state += elevator;
    return state;
}

void decode_state(unsigned int state, char floors[4][NUM_ITEMS], int *elevator) {
	*elevator = state & 3;
	state >>= 2;
	int flr;
	for ( int i = NUM_ITEMS-1; i >= 0; i-- ) {
		flr = state & 3;
		state >>= 2;
		for ( int f = 3; f >= 0; f-- ) {
			if ( flr == f ) {
				floors[f][i] = 1;
			} else {
				floors[f][i] = 0;
			}
		}
	}
}


typedef struct _deq {
	unsigned int state;
	int moves;
	struct _deq* next;
} deq;

deq* push_back(deq* qend, unsigned int state, int moves) {

	deq* item = malloc(sizeof(deq));
	item->state = state;
	item->moves = moves;
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

int main(){
	char floors[4][NUM_ITEMS];
	for (int i = 0; i < 4; i++ ) {
		for ( int j = 0; j < NUM_ITEMS; j++ ) {
			floors[i][j] = 0;
		}
	}
	
	floors[0][0] = 1;
	floors[0][NUM_KINDS +0] = 1;
	floors[1][NUM_KINDS +1] = 1;
	floors[1][NUM_KINDS +2] = 1;
	floors[1][NUM_KINDS +3] = 1;
	floors[1][NUM_KINDS +4] = 1;
	floors[2][1] = 1;
	floors[2][2] = 1;
	floors[2][3] = 1;
	floors[2][4] = 1;

#ifdef PART2
	floors[0][5] = 1;
	floors[0][6] = 1;
	floors[0][12] = 1;
	floors[0][13] = 1;
#endif
/*
	floors[0][0] = 1;
	floors[0][1] = 1;
	floors[1][2] = 1;
	floors[2][3] = 1;
*/

	unsigned int state = hash_state(floors,0);
	deq *start, *end, *curr;

	start = malloc(sizeof(deq));
	
	start->state = state;
	start->moves = 0;
	start->next = NULL;

	end = start;
	curr = start;

	unsigned int *seen_states = calloc(HASH_SIZE, sizeof(unsigned int));
//   	[HASH_SIZE] = { 0 };

	seen_states[state] = 1;

	int moves = 0;
	int elevator = 0;
	int ev_0;
	int ev_1;

	int done = 0;
	unsigned int qsize = 1;

	do {
		decode_state(curr->state, floors, &elevator);
		if ( moves < curr->moves ) {
			moves = curr->moves;
			printf("moves: %d, qsize: %u\n", moves, qsize);
		}
		/*
		printf("ev: %d, moves: %d, state: "BYTE_TO_BINARY_PATTERN BYTE_TO_BINARY_PATTERN BYTE_TO_BINARY_PATTERN" \n",
				elevator, curr->moves,
				BYTE_TO_BINARY( curr->state >> 16),
				BYTE_TO_BINARY( curr->state >> 8),
				BYTE_TO_BINARY(curr->state) );
				*/
		/*
		for ( int f = 3; f >= 0; f-- ) {
			printf("F%d %c", f+1, f == elevator ? 'E' : '.' );
			for ( int i = 0; i < NUM_ITEMS; i++ ) {
				printf(" %d", floors[f][i]);
			}
			printf("\n");
		}
*/
		if ( elevator == 3 ) {
			done = 1;
			for ( int i = 0; i < NUM_ITEMS; i++ ) {
				if ( floors[3][i] != 1 ) {
					done = 0;
					break;
				}
			}
			if ( done ) {
				moves = curr->moves;
				break;
			}
		}
		for ( int i = 0; i < NUM_ITEMS; i++ ) {
			if ( floors[elevator][i] ) {
				ev_0 = i;
				floors[elevator][i] = 0;

				for ( int j = i+1; j < NUM_ITEMS; j++ ) {
					if ( floors[elevator][j] ) {
						ev_1 = j;
						floors[elevator][j] = 0;
						if ( can_move(floors[elevator], j) ) {
							for ( int d = 1; d > -2; d-=2 ) {
								if ( elevator + d >= 0 && elevator + d < 4 ) {
									floors[elevator + d][ev_0] = 1;
									floors[elevator + d][ev_1] = 1;
									if ( floor_is_ok(floors[elevator+d]) ) {
										state = hash_state(floors,elevator+d);
										if ( !seen_states[state] ) {
											seen_states[state] = 1;
											end = push_back(end, state, curr->moves+1);
											qsize++;
										}
									}
									floors[elevator + d][ev_0] = 0;
									floors[elevator + d][ev_1] = 0;
								}
							}
						}
						floors[elevator][j] = 1;
					}
				}

				if ( can_move(floors[elevator], i) ) {
                	for ( int d = -1; d < 2; d+=2 ) {
                    	if ( elevator + d >= 0 && elevator + d < 4 ) {
							if ( elevator + d >= 0 && elevator + d < 4 ) {
								floors[elevator + d][ev_0] = 1;
								if ( floor_is_ok(floors[elevator+d]) ) {
									state = hash_state(floors,elevator+d);
									if ( !seen_states[state] ) {
										seen_states[state] = 1;
										end = push_back(end, state, curr->moves+1);
										qsize++;
									}
								}
								floors[elevator + d][ev_0] = 0;
							}
						}
					}
				}
				floors[elevator][i] = 1;
			}
		}

		start = curr;
		curr = curr->next;
		free(start);
		qsize--;
	} while ( curr != NULL );
	printf("min moves: %d\n", moves);

	cleanup_deq(curr);
//	*/
}
