#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

int main() {
	FILE *fp = fopen("input-09","r");
	if ( fp == NULL ) {
		printf("couldn't open file\n");
		exit(1);
	}
	int c;
	unsigned int cnt = 0;
	unsigned int x = 0;
	unsigned int y = 0;
	int in_brackets = 0;
	int reading_x = 0;
	while ( 1 ) {
	   	c = fgetc(fp);
		if ( feof(fp) ) {
			break;
		}
		if ( c == '(' ) {
			in_brackets = 1;
			reading_x = 1;
		} else if ( c == ')' ) {
			in_brackets = 0;
			cnt+= x*y;
			fseek(fp, x, SEEK_CUR);
			y = 0;
			x = 0;
		} else if ( in_brackets && c == 'x' ) {
			reading_x = 0;
		} else if ( in_brackets ) {
			if ( reading_x ) {
				x = x*10 + (c - '0');
			} else {
				y = y*10 + (c - '0');
			}
		} else if ( c >= ' ' ) {
		//	printf("%c - %d\n", c, c);
			cnt++;
		}
	}
	printf("length of decompressed string: (v1) %u\n", cnt);

	fseek(fp, 0, SEEK_SET);
	cnt = 0;
	int curr_x = -1;
	uint64_t stack[2000][4]; // 0 - x, 1 - y, 2 - cur_x, 3 - count in this level has to be 64 bits otherwise overlows are fun
	int stackp = 0;
	stack[0][3] = 0;
	in_brackets = 0;
    reading_x = 0;
	while ( 1 ) {
        c = fgetc(fp);
        if ( feof(fp) ) {
            break;
        }
		if ( curr_x > 0 ) {
			curr_x--;
		}
        if ( c == '(' ) {
			in_brackets = 1;
			reading_x = 1;
		} else if ( c == ')' ) {
            in_brackets = 0;
			stackp++;
			stack[stackp][0] = x;
			stack[stackp][1] = y;
			stack[stackp-1][2] = curr_x;
			stack[stackp][3] = 0; 	
			curr_x = x;
            y = 0;
            x = 0;
			continue;
		} else if ( in_brackets && c == 'x' ) {
            reading_x = 0;
        } else if ( in_brackets ) {
            if ( reading_x ) {
                x = x*10 + (c - '0');
            } else {
                y = y*10 + (c - '0');
            }
        }
		
		if ( !in_brackets && c >= ' ' ) {
            stack[stackp][3]++;
			if ( stackp >= 0 ) {
				while ( curr_x == 0 ) {
					stack[stackp][1]--;
					if ( stack[stackp][1] ) {
						stack[stackp][3] += stack[stackp][3] * stack[stackp][1];
						stack[stackp][1] = 1;
					} else {
						stackp--;
						curr_x = stack[stackp][2] - stack[stackp+1][0];
						stack[stackp][3] += stack[stackp+1][3];
					}
				}
			}
        }
	}
    printf("length of decompressed string: (v2) %" PRIu64 "\n", stack[0][3]);   
	fclose(fp);

}
