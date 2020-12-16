#include <stdio.h>
#include <string.h>
#include "_timer.h"

int main() {
    timer_start();
    int validators[20][2][2] = { 0 };
    int num_fields = 0;
    FILE *fp = fopen("input-16","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];

    int reading_validators = 1;
    int reading_your_ticket = 0;
    int reading_nearby_tickets = 0;
    unsigned int invalid_sum = 0;
    int my_ticket[20];
    int valid_tickets[256][20];
    int valid_ticket_cnt = 0;
    int validators_for_field[20][21]; // 0 stores the count of validators for this field, and the rest are validator indexes

    int is_valid = 0;
    while ( fgets(buff,255,fp) ) {
        if ( buff[0] == '\n' ) {
            if ( reading_validators ) {
                reading_validators = 0;
                reading_your_ticket = 1;
//                for ( int i = 0; i < num_fields; i++ ) {
//                    printf("validator: %d - %d || %d - %d\n", validators[i][0][0], validators[i][0][1], validators[i][1][0], validators[i][1][1]);
//                }
                for ( int i = 0; i < num_fields; i++ ){
                    validators_for_field[i][0] = num_fields;
                    for ( int k = 0; k < num_fields; k++ ) {
                        validators_for_field[i][k+1] = k; 
                    } 
                }
                continue;
            }
            if ( reading_your_ticket ) {
                reading_your_ticket = 0;
                reading_nearby_tickets = 1;
                continue;
            }
        }
        if ( reading_validators ) {
            int offset = 0;
            for ( ; buff[offset] != ':'; offset++ );
//            printf("%s", buff+offset);
            sscanf(buff+offset, ": %d-%d or %d-%d", &validators[num_fields][0][0], &validators[num_fields][0][1], &validators[num_fields][1][0], &validators[num_fields][1][1]);
            num_fields++;
            continue;
        }
        if ( reading_nearby_tickets ) {
            if ( buff[0] >= '0' && buff[0] <= '9' ) {
                int num = 0;
                int field = 0;
                int row_is_valid = 1;
                for ( int i = 0; buff[i]; i++ ) {
                    switch ( buff[i] ) {
                        case ',':
                        case '\n':
                            is_valid = 0;
                            for ( int k = 0; k < num_fields; k++ ) {
                                if ( ( num >= validators[k][0][0] && num <= validators[k][0][1] ) || ( num >= validators[k][1][0] && num <= validators[k][1][1] ) ) {
                                    is_valid = 1;
                                    break;
                                }
                            }
                            if ( !is_valid ) {
//                                printf("%d is invalid\n", num);
                                invalid_sum += num;
                                row_is_valid = 0;
                            }
                            valid_tickets[valid_ticket_cnt][field++] = num;
                            num = 0;
                            break;
                        default:
                            num = num*10 + buff[i] - '0';
                            break;
                    }
                }
                if ( row_is_valid ) {
                    valid_ticket_cnt++;
                }
            }
        }
        if ( reading_your_ticket ) { 
            if ( buff[0] >= '0' && buff[0] <= '9' ) {
                int num = 0;
                int field = 0;
                for ( int i = 0; buff[i]; i++ ) {
                    switch ( buff[i] ) {
                        case ',':
                        case '\n':
                            my_ticket[field++] = num;
                            num = 0;
                            break;
                        default:
                            num = num*10 + buff[i] - '0';
                            break;
                    }
                }
            }
        }
    }
    fclose(fp);
    printf("sum of invalid nrs: %u\n",invalid_sum);
    for ( int i = 0; i < valid_ticket_cnt; i++ ) {
/*        int all_validators_found = 1;
        for ( int k = 0; k < num_fields; k++ ) {
            if ( validators_for_field[k][0] > 1 ) {
                all_validators_found = 0;
                break;
            }
        }
        if ( all_validators_found ) {
            break;
        }
*/
        for ( int k = 0; k < num_fields; k++ ) {
            int num = valid_tickets[i][k];
            if ( validators_for_field[k][0] > 1 ) {
                for ( int j = 1; j - 1 < validators_for_field[k][0]; j++ ) {
                    int validator = validators_for_field[k][j];
                    if ( !( ( num >= validators[validator][0][0] && num <= validators[validator][0][1] ) || ( num >= validators[validator][1][0] && num <= validators[validator][1][1] ) ) ) {
//                        printf("validator %d is not good for field %d (because %d)\n", validator, k, num);
                        validators_for_field[k][j] = validators_for_field[k][validators_for_field[k][0]];
                        validators_for_field[k][0]--;
                        j--;
                    }
                }
            }
        }
    }
    for ( int i = 0; i < num_fields; i++ ) {
        if ( validators_for_field[i][0] == 1 ) {
            int did_remove = 0;
            for ( int k = 0; k < num_fields; k++ ) {
                if ( k == i ) continue;
                for ( int j = 1; j - 1 < validators_for_field[k][0]; j++ ) {
                    if ( validators_for_field[i][1] == validators_for_field[k][j] ) {
                        validators_for_field[k][j] = validators_for_field[k][validators_for_field[k][0]];
                        validators_for_field[k][0]--;
//                        printf("removed validator %d from field %d because it's the sole validator for %d\n",validators_for_field[i][1], k, i);
                        did_remove = 1;
                        break;
                    }
                }
            }
            if ( did_remove ) {
                i = -1; //start again
            }
        }
    }
    unsigned long mul = 1;
    for ( int f = 0; f < num_fields; f++ ) {
        if ( validators_for_field[f][1] < 6 ) {
            mul *=  my_ticket[f];
        }
/*        printf("%d is validated by %d validators: ", my_ticket[f], validators_for_field[f][0]);
        for ( int i = 1; i-1 <  validators_for_field[f][0]; i++ ) {
           printf(" %d ", validators_for_field[f][i]);
        }
        printf("\n"); 
*/    }
    printf("my magic number: %lu\n", mul);
    printtime();

}
