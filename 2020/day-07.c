#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "_timer.h"

typedef struct _childbag {
    int count;
    int id;
    char *name;
} childbag_t;

typedef struct _bag {
    char *name;
    char child_cnt;
    int id;
    unsigned int subbag_cnt;
    childbag_t *children;
} bag_t;

int main() {
    timer_start();
    FILE *fp = fopen("input-07","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];
    bag_t bags[600] = { (bag_t){ .name = NULL, .child_cnt = 0, .subbag_cnt = 0 } };
    int bag_cnt = 0;
    int has_bag_name = 0;
    int space_cnt = 0;
    int buff_start = 0;
    int comma_count = 0;
    int child_nr = 0;
    while ( fgets(buff, 255, fp) ) {
        buff_start = 0;
        has_bag_name = 0;
        space_cnt = 0;
        bags[bag_cnt].id = bag_cnt;
        //printf("parsing %s\n", buff);
        for ( int i = 0; buff[i] && buff[i] != '\n'; i++ ) {
            if ( buff[i] == ' ' ) {
                //printf("it's a space with i = %d, space count = %d\n", i, space_cnt);
                if ( space_cnt == 1 ) {
                    if ( has_bag_name == 0 ) {
                        bags[bag_cnt].name = (char *)malloc(i+1);
                        strncpy(bags[bag_cnt].name, buff, i);
                        has_bag_name = 1;
                        i += 13; //skip ahead by "bags contain "
                        if ( buff[i+1] == 'n' ) { //no other bags
                            break;
                        } else {
                            // look ahead and count the commas - the number of children is nr of , + 1 (and we need to malloc that shit)
                            comma_count = 0;
                            for ( int j = i; buff[j] != '\n'; j++ ) {
                                if ( buff[j] == ',' ) {
                                    comma_count++;
                                }
                            }
                            bags[bag_cnt].child_cnt = comma_count + 1;
                            bags[bag_cnt].children = malloc( sizeof(childbag_t) * (comma_count + 1));
                            child_nr = 0;
                        }
                        buff_start = i;
                        space_cnt = 0;
                    } else {
                        bags[bag_cnt].children[child_nr].name = (char *)malloc(i+1 - buff_start);
                        strncpy(bags[bag_cnt].children[child_nr].name, buff+buff_start, i-buff_start);
                        child_nr++;
                        space_cnt = 0;
                        i += buff[i+4] == 's' ? 6 : 5; //bloody plurals
                        
                        buff_start = i;
                        //printf("will resume parsing at %x (%d)\n", buff[i+1], i+1);
                    }
                } else {
                    space_cnt++;
                    continue;
                }
            } else if ( buff[i] >= '0' && buff[i] <= '9' ) {
                //printf("it's a number (%c) %d child_nr: %d\n", buff[i], i, child_nr);
                bags[bag_cnt].children[child_nr].count = buff[i] - '0';
                i++;
                buff_start = i+1;
            }
        }
        bag_cnt++;
    }
    int start_id = 0;
    for ( int i = 0; i < bag_cnt; i++ ) {
        for ( int j = 0; j < bags[i].child_cnt; j++ ) {
            for ( int k = 0; k < bag_cnt; k++ ) {
                if ( strcmp(bags[i].children[j].name, bags[k].name) == 0 ) {
                    bags[i].children[j].id = bags[k].id;
                    break;
                }
            }
        }
        if ( strcmp(bags[i].name, "shiny gold") == 0 ) {
            start_id = bags[i].id;
        }
    }
    int parents[bag_cnt][bag_cnt];
    for ( int i = 0; i < bag_cnt; i++ ) {
        for ( int j = 0; j < bag_cnt; j++ ) {
            parents[i][j] = -1;
        }
    }
    for ( int i = 0; i < bag_cnt; i++ ) {
        for ( int j = 0; j < bags[i].child_cnt; j++ ) {
            int k = 0;
            while ( parents[ bags[i].children[j].id ][k] != -1 ) {
                k++;
            }
            parents[ bags[i].children[j].id ][k] = bags[i].id;
        }
    }
    int seen[bag_cnt];
    for ( int i = 0; i < bag_cnt; i++ ) {
        seen[i] = 0;
    }
    int deq[bag_cnt * 4];
    int deq_st = 0;
    int deq_end = 0; 
    int seen_cnt = 0;
    for ( int i = 0; parents[ start_id ][i] != -1; i++ ) {
        seen[ parents[ start_id ][i] ] = 1;
        seen_cnt++;
        deq[deq_end++] =  parents[ start_id ][i];
 //       printf("added %s to seen\n", bags[ parents[ start_id ][i] ].name);
    }
//    printf("now processing the queue\n");
    while ( deq_st != deq_end ) {
/*        printf("current queue: \n");
        for ( int i = deq_st; i != deq_end; i = (i + 1) % (bag_cnt * 4) ) {
            printf(" - %s\n", bags[ deq[i] ].name );
        }
*/        for ( int i = 0; parents[ deq[ deq_st ] ][i] != -1; i++ ) {
            if ( !seen[ parents[ deq[ deq_st ] ][i] ] ) {
                seen[ parents[ deq[ deq_st ] ][i] ] = 1;
//                printf("added %s to seen\n", bags[ parents[ deq[deq_st] ][i] ].name);
                seen_cnt++;
                deq[deq_end] = parents[ deq[ deq_st ] ][i];
                deq_end = (deq_end+1) % (bag_cnt*4);
            }
        }
        deq_st = (deq_st + 1) % (bag_cnt*4);
/*        printf("current queue: \n");
        for ( int i = deq_st; i != deq_end; i = (i + 1) % (bag_cnt * 4) ) {
            printf(" - %s\n", bags[ deq[i] ].name );
        }*/
//        printf("gimmmesegfault %d", deq[1231231]);
    }
    printf("seen: %d\n", seen_cnt);
   
    int stack[bag_cnt];
    int depth = 1;
    stack[0] = start_id;
    while ( depth ) {
        if ( bags[ stack[depth - 1] ].child_cnt == 0 ) {
           bags[ stack[depth - 1] ].subbag_cnt = 1;
        } 
        if ( bags[ stack[depth - 1] ].subbag_cnt == 0 ) {
            int cnt = 1;
            int all_count = 1;
            for ( int i = 0; i < bags[ stack[ depth - 1 ] ].child_cnt; i++ ) {
                if ( bags[ bags[ stack[ depth - 1 ] ].children[i].id ].subbag_cnt == 0 ) {
                    stack[depth] = bags[ stack[ depth - 1 ] ].children[i].id;
                    depth++;
                    all_count = 0;
                    break;
                } else {
                    cnt += bags[ bags[ stack[ depth - 1 ] ].children[i].id ].subbag_cnt * bags[ stack[ depth - 1 ] ].children[i].count;
                }
            }
            if ( all_count ) {
                bags[ stack[depth - 1] ].subbag_cnt = cnt;
                depth--;
            }
        } else {
            depth--;
        }
    }

    printf("subbag count %u\n", bags[start_id].subbag_cnt  - 1);

    /* 
    for ( int i = 0; i < bag_cnt; i++ ) {
        printf("\nbag %s (%d) has %d children\n", bags[i].name, bags[i].id,  bags[i].child_cnt);
        for ( int j = 0; j < bags[i].child_cnt; j++ ) {
            printf("  %d %s (%d)\n", bags[i].children[j].count, bags[i].children[j].name, bags[i].children[j].id);
        }
    }
    */
    printtime();
}
