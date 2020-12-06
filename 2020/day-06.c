#include <stdio.h>
#include "_timer.h"

int main() {
    timer_start();
    FILE *fp = fopen("input-06","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];
    int total_answers = 0;
    int total_answers_part2 = 0;
    int answers_this_group = 0;
    int nr_answers_this_group = 0;
    int answers_this_person = 0;
    int answers_this_group_part_2 = 0x7FFFFFF;
    while ( fgets(buff, 255, fp) ) {
        if ( buff[0] == '\n' ) {
            nr_answers_this_group = 0;
            while ( answers_this_group ) {
                nr_answers_this_group += answers_this_group & 1;
                answers_this_group >>= 1;
            }
            total_answers += nr_answers_this_group;
            nr_answers_this_group = 0;
            while ( answers_this_group_part_2 ) {
                nr_answers_this_group += answers_this_group_part_2 & 1;
                answers_this_group_part_2 >>= 1;
            }
            total_answers_part2 += nr_answers_this_group;
            answers_this_group_part_2 = 0x7FFFFFF;
            continue;
        }
        answers_this_person = 0;
        for ( int i = 0; buff[i] >= 'a'; i++ ) {
            answers_this_group = answers_this_group | (1 << (buff[i] - 'a'));
            answers_this_person = answers_this_person | (1 << (buff[i] - 'a'));
        }
        answers_this_group_part_2 = answers_this_group_part_2 & answers_this_person;
    }
    fclose(fp);
    if ( answers_this_group ) {
        nr_answers_this_group = 0;
        while ( answers_this_group ) {
            nr_answers_this_group += answers_this_group & 1;
            answers_this_group >>= 1;
        }
        total_answers += nr_answers_this_group;
        nr_answers_this_group = 0;
        while ( answers_this_group_part_2 ) {
            nr_answers_this_group += answers_this_group_part_2 & 1;
            answers_this_group_part_2 >>= 1;
        }
        total_answers_part2 += nr_answers_this_group;
    }
    printf("number of answers in different groups: %d\n", total_answers);
    printf("number of answers in different groups part 2: %d\n", total_answers_part2);
    printtime();
}
