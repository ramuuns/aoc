#include <stdio.h>
#include "_timer.h"

//#define PK_CARD 5764801 
//#define PK_DOOR 17807724

#define PK_CARD 15335876
#define PK_DOOR 15086442

int main() {
    timer_start();
    unsigned long keys[2] = { 1, 1 };
    unsigned long private_key[2] = { 1, 1 };
    int found_idx = 0;
    while(1) {
        keys[0] = (keys[0] * 7) % 20201227;
        keys[1] = (keys[1] * 7) % 20201227;
        private_key[0] = ( private_key[0] * PK_DOOR ) % 20201227;
        private_key[1] = ( private_key[1] * PK_CARD ) % 20201227;
        if ( keys[0] == PK_CARD ) {
            found_idx = 0;
            break;
        }
        if ( keys[1] == PK_DOOR ) {
            found_idx = 1;
            break;
        }
    };

    printf("encryption key: %lu\n", private_key[found_idx]);
    printtime();
}
