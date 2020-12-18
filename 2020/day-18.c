#include <stdio.h>
#include "_timer.h"

int main() {
    timer_start();
    FILE *fp = fopen("input-18","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    unsigned long sum = 0;
    unsigned long sum2 = 0;
    unsigned int n = 0;
    unsigned long stack[30][2]; // [ [ number, op (0 add, 1 = multiply ] ]
    unsigned long stack2[30][30]; // [ [ nr of terms, term1, term2 ... ] ]
    int sp = 0;
    
    char buff[255];
    while ( fgets(buff, 255, fp) ) {
        n = 0;
        int prev_was_op = 0;
        stack[0][0] = 0;
        stack[0][1] = 0;

        stack2[0][0] = 0;
        stack2[0][1] = 0;

        for ( int i = 0; buff[i] != '\n'; i++ ) {
           /* 
            printf("\n%c %d stack:\n", buff[i], n);
            for ( int k = 0; k <= sp; k++ ) {
                printf("%d %lu %c ", k, stack2[k][0], stack[k][1] ? '*' : '+');
                for ( int j = 0; j < stack2[k][0] + 1; j++ ) {
                    printf("%lu ", stack2[k][j+1]);
                }
                printf("\n");
            }
            */
            switch( buff[i] ) {
                case '+':
                case '*':
                    stack[sp][1] = buff[i] == '*' ? 1 : 0;
                    prev_was_op = 1;
                    break;
                case ' ':
                    if ( !prev_was_op && n ) {
                        stack[sp][0] = stack[sp][1] ? stack[sp][0] * n : stack[sp][0] + n;
                        // if the last op was multiplaction set the new number as a new term   
                        if ( stack[sp][1] ) {
                            stack2[sp][ 1 + (++stack2[sp][0]) ] = n;
                        } else {
                        // otherwise add it to the last term
                            stack2[sp][ 1 + stack2[sp][0] ] += n;
                        }
                        n = 0;
                    }
                    break;
                case '(':
                    sp++;
                    stack[sp][0] = 0;
                    stack[sp][1] = 0;
                    
                    stack2[sp][0] = 0;
                    stack2[sp][1] = 0;
                    break;
                case ')':
                    if ( n ) {
                        stack[sp][0] = stack[sp][1] ? stack[sp][0] * n : stack[sp][0] + n;

                        if ( stack[sp][1] ) {
                            stack2[sp][ 1 + (++stack2[sp][0]) ] = n;
                        } else {
                            stack2[sp][ 1 + stack2[sp][0] ] += n;
                        }
                        n = 0;
                    }
                    stack[sp-1][0] = stack[sp-1][1] ? stack[sp-1][0] * stack[sp][0] : stack[sp-1][0] + stack[sp][0];

                    //for part 2 just reduce all the terms in this stack level to a single number
                    for ( int k = 0; k < stack2[sp][0]; k++ ) {
                        stack2[sp][1] *= stack2[sp][2 + k];
                    }
                    // and then pass it up higher either as a new term or add it to the last term (depending on the last op)
                    if ( stack[sp-1][1] ) {
                        stack2[sp-1][ 1 + (++stack2[sp-1][0]) ] = stack2[sp][1];
                    } else {
                        stack2[sp-1][ 1 + stack2[sp-1][0] ] += stack2[sp][1];
                    }
                    sp--;
                    break;
                default:
                    n = n*10 + buff[i] - '0';
                    prev_was_op = 0;
                    break;
            }
        }
        if ( n ) {
            stack[sp][0] = stack[sp][1] ? stack[sp][0] * n : stack[sp][0] + n;

            //since this was the last number, we can do the same as for part 1, but with the last term instead
            stack2[sp][ 1 + stack2[sp][0] ] = stack[sp][1] ?
                stack2[sp][ 1 + stack2[sp][0] ] * n :
                stack2[sp][ 1 + stack2[sp][0] ] + n;
            n = 0;
        }
        for ( int k = 0; k < stack2[sp][0]; k++ ) {
            stack2[sp][1] *= stack2[sp][2 + k];
        }
        sum += stack[sp][0];
        sum2 += stack2[sp][1];
    }

    printf("sum: %lu\n", sum);
    printf("advanced sum: %lu\n", sum2);
    

    printtime();
}
