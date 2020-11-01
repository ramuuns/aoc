#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INPUT "10011111011011001"

#define TGT_SIZE1 272

#define TGT_SIZE 35651584

int main() {
    char *buffer = calloc(TGT_SIZE, sizeof(char));
    const char *input = INPUT;
    int l = strlen(input);
    for ( int i = 0; i < l; i++ ) {
        buffer[i] = input[i] - '0';
    }
    while ( l < TGT_SIZE ) {
        buffer[l] = 0;
        for ( int k = 0; k < l && l+k+1 < TGT_SIZE; k++ ) {
            buffer[l+k+1] = !buffer[l-k-1];
        }
        l = l*2 + 1;
    }

    int checksum_l = TGT_SIZE;
    do {
        checksum_l >>= 1;
        for ( int i = 0; i < checksum_l; i++ ) {
            buffer[i] = !(buffer[i*2] ^ buffer[i*2+1]);
        }
    } while ( (checksum_l & 1) == 0 );

    printf("checksum: ");
    for ( int i = 0; i < checksum_l; i++ ) {
        printf("%d", buffer[i]);
    }
    printf("\n");
    free(buffer);
}

