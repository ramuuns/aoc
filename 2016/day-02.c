#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "libs.h"

int main() {
	char* data = read_file("input-02");
	uint64_t keypad[3][3] = {
		{ 1, 2, 3 },
		{ 4, 5, 6 },
		{ 7, 8, 9 }
	};
	int x = 1;
	int y = 1;
	uint64_t code = 0;
	size_t l = strlen(data);
	char last_was_newline = 0;
	for ( int c = 0; c < l+1; c++ ) {
		switch(data[c]){
			case 0:
			case '\n':
				if ( !last_was_newline ) {
					code = code*10 + keypad[y][x];
					last_was_newline = 1;
				}
				break;
			case 'L':
				if ( x > 0 ) { x--; }
				last_was_newline = 0;
				break;
			case 'R':
				if ( x < 2 ) { x++; }
				last_was_newline = 0;
				break;
			case 'U':
				if ( y > 0 ) { y--; }
				last_was_newline = 0;
				break;
			case 'D':
				if ( y < 2 ) { y++; }
				last_was_newline = 0;
				break;
			default:
				printf("unknown character detected, possibly bad input data: %c\n", data[c]);
				exit(1);
				break;
		}
	}
	printf("\nCode: %" PRIu64 "\n", code);

	char keypad2[5][5] = {
		{   0,   0, '1',   0,  0 },
		{   0, '2', '3', '4',  0 },
		{ '5', '6', '7', '8', '9'},
		{   0, 'A', 'B', 'C',  0 },
		{   0,   0, 'D',   0,  0 }
	};

	last_was_newline = 0;
	x = 0;
	y = 2;

	printf("Second code: ");
	for ( int c = 0; c < l+1; c++ ) {
        switch(data[c]){
            case 0:
            case '\n':
                if ( !last_was_newline ) {
                    printf("%c", keypad2[y][x]);
                    last_was_newline = 1;
                }
                break;
            case 'L':
                if ( x > 0 && keypad2[y][x-1] ) { x--; }
                last_was_newline = 0;
                break;
            case 'R':
                if ( x < 4 && keypad2[y][x+1] ) { x++; }
                last_was_newline = 0;
                break;
            case 'U':
                if ( y > 0 && keypad2[y-1][x] ) { y--; }
                last_was_newline = 0;
                break;
            case 'D':
                if ( y < 4 && keypad2[y+1][x] ) { y++; }
                last_was_newline = 0;
                break;
            default:
                printf("unknown character detected, possibly bad input data: %c\n", data[c]);
                exit(1);
                break;
        }
    }

	printf("\n");

	free(data);

}
