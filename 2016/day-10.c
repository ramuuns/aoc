#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct _bot {
	int x;
	int y;
	int low_idx;
	int high_idx;
	char low_is_bot;
	char high_is_bot;
} bot;

#define TGT_LOW 17
#define TGT_HIGH 61

int main() {
	FILE *fp = fopen("input-10","r");
	if ( fp == NULL ) {
		printf("no bueno\n");
		exit(1);
	}
	char buff[255];
	bot bots[255];
	for ( int i = 0; i < 255; i++ ) {
		bots[i].x = 0;
		bots[i].y = 0;
	}
	int active_bot = -1;
	char cmd[40];
	char cmdb[40];
	int bot_nr;
	int low_nr;
	int high_nr;
	int active_stack[255] = { 0 };
	int active_sp = 0;
	while ( fgets(buff, 255, fp ) ) {
		sscanf(buff, "%s ", cmd);
		if ( strlen(cmd) == 3 ) { //bot
			sscanf(buff, "bot %d gives low to %s %d and high to %s %d", &bot_nr, cmd, &low_nr, cmdb, &high_nr);
			bots[bot_nr].low_idx = low_nr;
			bots[bot_nr].high_idx = high_nr;
			bots[bot_nr].low_is_bot = strlen(cmd) == 3 ? 1 : 0;
			bots[bot_nr].high_is_bot = strlen(cmdb) == 3 ? 1 : 0;
		} else { // value
			sscanf(buff, "value %d goes to bot %d", &low_nr, &bot_nr);
			if ( bots[bot_nr].x ) {
				bots[bot_nr].y = low_nr;
				active_stack[active_sp++] = bot_nr;
			} else {
				bots[bot_nr].x = low_nr;
			}
		}
	}
	fclose(fp);
	int low;
	int high;
	int next_bot;
	int output[3] = {0};
	while ( active_sp >= 0 ) {
		active_bot = active_stack[--active_sp];
//		printf("active bot: %d has %d, %d\n", active_bot, bots[active_bot].x, bots[active_bot].y);
 		low = bots[active_bot].x > bots[active_bot].y ? bots[active_bot].y : bots[active_bot].x;
		high = bots[active_bot].x < bots[active_bot].y ? bots[active_bot].y : bots[active_bot].x;
		if ( low == TGT_LOW && high == TGT_HIGH ) {
		   printf("bot comparing target numbers is %d\n", active_bot);
		   //break;
		}
		if ( bots[active_bot].low_is_bot ) {
			if ( bots[ bots[active_bot].low_idx ].x ) {
				bots[ bots[active_bot].low_idx ].y = low;
				active_stack[active_sp++] = bots[active_bot].low_idx;
				//printf("gave low (%d) to %d who should next become active\n", low, bots[active_bot].low_idx); 
			} else {
				bots[ bots[active_bot].low_idx ].x = low;
				//printf("gave low to %d\n", bots[active_bot].low_idx);
			}
		} else {
			//meh
			if ( bots[active_bot].low_idx < 3 ) {
				output[bots[active_bot].low_idx] = low;
				if ( output[0] * output[1] * output[2] ) {
					printf("multiply!: %d\n", output[0] * output[1] * output[2]);
					break;
				}
			}
		}
		if ( bots[active_bot].high_is_bot ) {
			if ( bots[ bots[active_bot].high_idx ].x ) {
                bots[ bots[active_bot].high_idx ].y = high;
                active_stack[active_sp++] = bots[active_bot].high_idx;
				//printf("gave high (%d) to %d who should next become active\n", high, bots[active_bot].high_idx); 
            } else {
                bots[ bots[active_bot].high_idx ].x = high;
				//printf("gave high to %d\n", bots[active_bot].high_idx);
            }
		} else {
			//meh
			if ( bots[active_bot].high_idx < 3 ) {
                output[bots[active_bot].high_idx] = high;
                if ( output[0] * output[1] * output[2] ) {
                    printf("multiply!: %d\n", output[0] * output[1] * output[2]);
                    break;
                }
            }
		}
	}
}

