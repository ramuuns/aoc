#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

typedef struct _cup {
    unsigned int nr;
    struct _cup *next;
} cup_t;

#define TURNS 100
#define CUPS 3,6,8,1,9,5,7,4,2 
//3,8,9,1,2,5,4,6,7

int main() {
    timer_start();
    int s_cups[9] = { CUPS };
    cup_t cups[9];
    cup_t *cup_map[10];
    for ( int i = 0; i < 9; i++ ) {
        cups[i].nr = s_cups[i];
        cups[i].next = &cups[(i+1)%9];
        cup_map[cups[i].nr] = &cups[i];
    }
    cup_t *head = &cups[0];
    for ( int i = 0; i < TURNS; i++ ) {
//        printf("-- move %d --\n", i+1);
//        cup_t *phead = head;
//        printf("cups: (%d) ", head->nr);
//        while ( phead->next->nr != head->nr ) { printf("%d ", phead->next->nr); phead = phead->next; } printf("\n");
        cup_t *skipped = head->next;
//        printf("pick up: %d, %d, %d\n", skipped->nr, skipped->next->nr, skipped->next->next->nr);
        head->next = skipped->next->next->next;
        cup_t *ins_after = head->next;
        for ( int k = 1; k < 10; k++ ) {
            int tgt = (head->nr - k + 10) % 10;
            if ( tgt == 0 ) {
                continue;
            }
            if ( skipped->nr == tgt || skipped->next->nr == tgt || skipped->next->next->nr == tgt ) {
                continue;
            }
            ins_after = cup_map[tgt];
            break;
        }
//        printf("destination: %d\n", ins_after->nr);
        skipped->next->next->next = ins_after->next;
        ins_after->next = skipped;

        head = head->next;
    }
    cup_t *phead = cup_map[1];
    while ( phead->next->nr != 1 ) { printf("%d", phead->next->nr); phead = phead->next; }
    printf("\n");

    cup_t *p2_cups = malloc(1000000 * sizeof(cup_t));
    cup_t **p2_cup_map = malloc(1000001 * sizeof(cup_t*));
    for ( int i = 0; i < 1000000; i++ ) {
        if ( i < 9 ) {
            p2_cups[i].nr = s_cups[i];
        } else {
            p2_cups[i].nr = i+1;
        }
        p2_cups[i].next = &p2_cups[(i+1) % 1000000 ];
        p2_cup_map[p2_cups[i].nr] = &p2_cups[i];
    }

    head = p2_cups;
    for ( int i = 0; i < 10000000; i++ ) {
//        printf("-- move %d --\n", i+1);
//        cup_t *phead = head;
//        printf("cups: (%d) ", head->nr);
//        while ( phead->next->nr != head->nr ) { printf("%d ", phead->next->nr); phead = phead->next; } printf("\n");
        cup_t *skipped = head->next;
//        printf("pick up: %d, %d, %d\n", skipped->nr, skipped->next->nr, skipped->next->next->nr);
        head->next = skipped->next->next->next;
        cup_t *ins_after = head->next;
        for ( int k = 1; k < 1000000; k++ ) {
            int tgt = (head->nr - k + 1000001) % 1000001;
            if ( tgt == 0 ) {
                continue;
            }
            if ( skipped->nr == tgt || skipped->next->nr == tgt || skipped->next->next->nr == tgt ) {
                continue;
            }
            ins_after = p2_cup_map[tgt];
            break;
        }
//        printf("destination: %d\n", ins_after->nr);
        skipped->next->next->next = ins_after->next;
        ins_after->next = skipped;

        head = head->next;
    }
    unsigned long mul = p2_cup_map[1]->next->nr;
    mul *= p2_cup_map[1]->next->next->nr;
    printf("multiplying: %lu\n", mul);
    free(p2_cup_map);
    free(p2_cups);
    printtime();
}
