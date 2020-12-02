#include <stdio.h>

int main() {
    FILE *fp = fopen("input-02","r");
    if ( !fp ) {
        printf("could not open file\n");
        return 1;
    }
    int min, max, valid_count = 0;
    int valid_part2 = 0;
    char c;
    char pwd[255];
    char buff[255];
    int char_cnt;
    while ( fgets(buff, 255, fp) ) {
        sscanf(buff, "%d-%d %c: %s", &min, &max, &c, pwd);
        char_cnt = 0;
        for ( int i = 0; pwd[i]; i++ ) {
            char_cnt += pwd[i] == c ? 1 : 0;
        }
        if ( char_cnt >= min && char_cnt <= max ) {
            valid_count++;
        }
        if ( pwd[min - 1] != pwd[max - 1] && ( pwd[min-1] == c || pwd[max-1] == c ) ) {
            valid_part2++;
        }
    }
    printf("nr of valid passwords %d\n", valid_count);
    printf("nr of valid passwords (part 2) %d\n", valid_part2);
}
