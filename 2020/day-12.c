#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"


int main() {
    timer_start();
    FILE *fp = fopen("input-12","r");

    // N E S W ( X , Y )
    char directions[4][2] = { { 0, 1 }, { 1, 0  }, { 0, -1 }, { -1, 0 } };
    char dir = 1;
    int x = 0;
    int y = 0;
    char c;
    int d;
    char buff[10];
    int w_x = 10;
    int w_y = 1;
    int s_x = 0;
    int s_y = 0;
    while (fgets(buff, 10, fp) ) {
        if ( buff[0] == '\n' ) {
            continue;
        }
        sscanf(buff, "%c%d", &c, &d);
        switch ( c ) {
            case 'N':
                y += d;
                w_y += d;
                break;
            case 'S':
                y -= d;
                w_y -= d;
                break;
            case 'E':
                x += d;
                w_x += d;
                break;
            case 'W':
                x -= d;
                w_x -= d;
                break;
            case 'F':
                x += directions[dir][0] * d;
                y += directions[dir][1] * d;
                s_x += w_x*d;
                s_y += w_y*d;
                break;
            case 'L':
                dir = (dir + 4 - d/90) % 4;
                if ( d == 180 ) {
                    w_x = -w_x;
                    w_y = -w_y;
                } else {
                    if ( d == 90 ) {
                        int tmp = w_x;
                        w_x = -w_y;
                        w_y = tmp;
                    } else { //d == 270
                        int tmp = w_x;
                        w_x = w_y;
                        w_y = -tmp;
                    }
                }
                break;
            case 'R':
                dir = (dir + d/90) % 4;
                if ( d == 180 ) {
                    w_x = -w_x;
                    w_y = -w_y;
                } else {
                    if ( d == 270 ) {
                        int tmp = w_x;
                        w_x = -w_y;
                        w_y = tmp;
                    } else { //d == 90
                        int tmp = w_x;
                        w_x = w_y;
                        w_y = -tmp;
                    }
                }
                break;
            default:
                printf("bad input: %s\n", buff);
                return 1;
        }
    }
    fclose(fp);
    printf("distance: %d\n", abs(x) + abs(y));
    printf("distance part 2: %d\n", abs(s_x) + abs(s_y));
    printtime();    
}
