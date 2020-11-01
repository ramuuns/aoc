#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INPUT "^.....^.^^^^^.^..^^.^.......^^..^^^..^^^^..^.^^.^.^....^^...^^.^^.^...^^.^^^^..^^.....^.^...^.^.^^.^" 

#define ROWS 400000
#define ROWS1 40

int main() {
    const char* input = INPUT;
    int l = strlen(input);
    char* row = calloc(l + 2, sizeof(char));
    int num_safe = 0;
    for ( int i = 1; i < l + 1; i++ ) {
        row[i] = input[i-1] == '^' ? 1 : 0;
        num_safe += !row[i];
    }
    int n = ROWS - 1;
    char p = 0;
    char t = 0;
    do {
        /*
        for ( int i = 1; i < l + 1; i++ ) {
            printf("%c", row[i] + '0');
        }
        printf("\n safe: %d \n", num_safe);
        */
        n--;
        p = 0;
        for ( int i = 1; i < l+1; i++ ) {
           t = p ^ row[i+1];
           p = row[i];
           row[i] = t;
           num_safe += !t;
        }
        if ( ROWS - n == ROWS1 ) {
            printf("safe part 1 %d\n", num_safe);
        }
    } while (n);
    printf("total safe: %d\n", num_safe);
    free(row);
}
