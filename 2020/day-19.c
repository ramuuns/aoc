#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "_timer.h"

int match_rules(unsigned char rules[140][7], int rule, char *buff, int bufflen, int depth);

void match_rule8(unsigned char rules[140][7], int rule, char *buff, int bufflen, int depth, int ret[40]) {

    //int ret[40] = { 0 };
    int num_applied = 0;
    int total_r = 0;
    int r = 0;
    do {
        r = match_rules(rules, 42, buff + total_r, bufflen - total_r, depth+1);
        if ( r ) {
            total_r+=r;
            ret[ 1 + num_applied++] = total_r;
        }
    } while ( r );
    ret[0] = num_applied;
    //return ret;
}

int match_rules(unsigned char rules[140][7], int rule, char *buff, int bufflen, int depth) {
    if ( bufflen <= 0 ) {
        return 0;
    }
/*    for ( int i = 0; i < depth; i++) printf(" ");
    printf("will try to match ");
    for ( int i = 0; i < bufflen; i++ ) {
        printf("%c", *(buff+i));
    }
    printf(" against rule %d (%d)\n", rule, rules[rule][0]);
*/    int ret = 0;
    if ( rules[rule][0] == 10 ) {
        ret = *buff == rules[rule][2];
//        printf(" %c %d\n", rules[rule][1], ret);
    } else if ( rules[rule][1] == 0 ) {
        if ( rule == 0 && rules[8][0] == 3 ) {
            int options[40] = { 0 };
            match_rule8(rules, 8, buff, bufflen, depth+1, options);

            for ( int op = 0; op < options[0]; op++ ) {
                int r = match_rules(rules, 11, buff + options[1 + op], bufflen - options[ 1+ op], depth+1);
                if ( r && r +  options[1 + op] == bufflen ) {
                    return bufflen;
                }
            }
        } else {
        for ( int k = 0; k < rules[rule][0]; k++ ) {
            if ( rule == rules[rule][2+k] ) {
                printf("wtf rule %d has rules \n", rule);
                for ( int l = 0; l < rules[rule][0]; l++ ) {
                    printf("%d", rules[rule][2+l]);
                }
                printf("\n");
                exit(1);
            }

            int r = match_rules(rules, rules[rule][2+k], buff + ret, bufflen - ret, depth+1);
            if ( !r ) {
//                for ( int i = 0; i < depth; i++) printf(" ");
//                printf("did not match\n");
                return 0;
            }
            ret += r;
        }
        }
//        for ( int i = 0; i < depth; i++) printf(" ");
//        printf("got %d %d\n", rules[rule][1], ret);
    } else {
        for ( int k = 0; k < rules[rule][0]; k++ ) {
            if ( k == rules[rule][1] ) {
                if ( ret ) {
                    break;
                }
            }
            int r = match_rules(rules, rules[rule][2+k], buff + ret, bufflen - ret, depth+1);
            if ( !r ) {
                ret = 0;
                if ( k < rules[rule][1] ) {
                    k = rules[rule][1] - 1;
                    continue;
                } else {
                    break;
                }
            } else {
                ret += r;
            }
        }
//        for ( int i = 0; i < depth; i++) printf(" ");
//        printf("got %d\n", ret);
    }
//    for ( int i = 0; i < depth; i++) printf(" ");
//    printf("got %d\n", ret);
    return ret;
}

int main() {
    timer_start();

    FILE *fp = fopen("input-19","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];
    unsigned char rules[140][7] = { 0 };
    unsigned char rules2[140][7] = { 0 };
    char reading_rules = 1;
    int matched_count = 0;
    int matched_count2 = 0;
    while ( fgets(buff, 255, fp) ) {
        if (reading_rules) {
            if ( buff[0] == '\n' ) {
                reading_rules = 0;
                for ( int i = 0; i < 140; i++ ) {
                    for ( int j = 0; j<6; j++ ) {
                        rules2[i][j] = rules[i][j];
                    }
                }
                rules2[8][0] = 3;
                rules2[8][1] = 2;
                rules2[8][2] = 42;
                rules2[8][3] = 8;
                rules2[8][4] = 42;
                
                rules2[11][0] = 5;
                rules2[11][1] = 3;
                rules2[11][2] = 42;
                rules2[11][3] = 11;
                rules2[11][4] = 31;
                rules2[11][5] = 42;
                rules2[11][6] = 31;
                continue;
            }
            int n = 0;
            int key = 0;
            int num_values = 0;
            for ( int i = 0; buff[i]; i++ ) {
                switch(buff[i]) {
                    case ' ':
                        if ( n ) {
                            rules[key][2 + num_values++] = n;
                            n = 0;
                        }
                        break;
                    case '\n':
                        if ( n ) {
                            rules[key][2 + num_values++] = n;
                            n = 0;   
                        } 
                        if ( num_values ) {
                            rules[key][0] = num_values;
                        }

                        break;
                    case ':':
                        key = n;
                        n = 0;
                        break;
                    case '|':
                        rules[key][1] = num_values;
                        break;
                    case '"':
                        rules[key][0] = 10;
                        rules[key][2] = buff[i+1];
                        i += 2; //
                        break;
                    default:
                        n = n*10 + buff[i] - '0';
                        break;
                }
            }
            /*
            printf("%s %d: ", buff, key);
            if ( rules[key][0] == 10 ) {
                printf("\"%c\"\n", rules[key][1]);
            } else {
                if ( rules[key][0] < 4 ) {
                    for( int j = 0; j < rules[key][0]; j++) printf("%d ", rules[key][1+j]);
                    printf("\n");
                } else {
                    printf("%d %d | %d %d\n", rules[key][1],rules[key][2],rules[key][3],rules[key][4]);
                }
            }
            */
        } else {
//            printf("will try to match %s", buff);
            int l = strlen(buff) - 1;
            matched_count += match_rules(rules, 0, buff, l, 0) == l ? 1 : 0;
            //printf("%d %d\n", match_rules(rules2, 0, buff, l, 0), l);
            matched_count2 += match_rules(rules2, 0, buff, l, 0) == l ? 1 : 0;
        }
    }

    printf("nr of matched rules: %d\n", matched_count);
    printf("nr of matched rules2: %d\n", matched_count2);
    printtime();
}
