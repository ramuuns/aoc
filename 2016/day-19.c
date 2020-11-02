#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOTAL 3014603

typedef struct _list {
    unsigned int nr;
    struct _list* next;
} list;

int main() {
    list *start, *end;
    start = malloc(sizeof(list));
    end = start;
    start->nr = 1;
    for ( unsigned int i = 2; i <= TOTAL; i++ ) {
        end->next = malloc(sizeof(list));
        end = end->next;
        end->nr = i;
    }
    end->next = start;
    while ( start->next != start ) {
        end = start->next;
        start->next = end->next;
        start = start->next;
        //printf("removing %u\n", end->nr);
        free(end);
    }

    printf("lucky elf: %u\n", start->nr);
    free(start);

    unsigned int *elfs = malloc(sizeof(unsigned int) * TOTAL);
    unsigned int items = TOTAL;
    for ( unsigned int i = 0; i < TOTAL; i++ ) {
        elfs[i] = i+1;
    }
    unsigned int curr = 0;
    unsigned int rm = 0;
    unsigned int _min_tgt;
    //int skipped = 0;
    //int rounds = 1;
    while ( items > 1 ) {
        rm = (curr + items/2)%items;
      //  printf("at %u, removing %u (%u)\n", elfs[curr], elfs[rm], rm);
        memmove(elfs + rm, elfs + rm +1, (items - rm - 1)* sizeof(unsigned int) );
        items--;
        /*for ( int i =0; i < items; i++ ) {
           printf("%d ", elfs[i]);
        }
        printf("\n");
        */
        if ( rm < curr ) {
            curr--;
        }
        curr = (curr + 1)%items;
    }
    printf("lucky elf: %u\n", elfs[0]);
    free(elfs);
}
