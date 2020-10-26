#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WIDTH 50
#define HEIGHT 6

void rect(char buf[HEIGHT][WIDTH], int x, int y) {
	for ( int i = 0; i < y; i++ ) {
		for ( int j = 0; j < x; j++ ) {
			buf[i][j] = '#';
		}
	}
}

void rotate_row(char buf[HEIGHT][WIDTH], int y, int by) {
//	printf("gonna rotate row %d by %d\n", y, by);
	char tmp[WIDTH];
	for ( int i = 0; i < WIDTH; i++ ) {
		tmp[i] = buf[y][i];
	}
	for ( int i = 0; i < WIDTH; i++ ) {
		buf[y][i] = tmp[(i + WIDTH - by) % WIDTH];
	}
}

void rotate_col(char buf[HEIGHT][WIDTH], int x, int by) {
//	printf("gonna rotate column %d by %d\n", x, by);
	char tmp[HEIGHT];
	for ( int i = 0; i < HEIGHT; i++ ) {
		tmp[i] = buf[i][x];
	}
	for ( int i = 0; i < HEIGHT; i++) {
		buf[i][x] = tmp[(i + HEIGHT - by) % HEIGHT];
	}
}

void draw_screen(char buf[HEIGHT][WIDTH]) {
	printf("\n");
	for ( int y = 0; y < HEIGHT; y++ ) {
		for (int x = 0; x < WIDTH; x++ ) {
			printf("%c", buf[y][x]);
		}
		printf("\n");
	}
	printf("\n");
}

int main() {
	char buf[HEIGHT][WIDTH];
	for ( int y = 0; y < HEIGHT; y++ ) {
        for ( int x = 0; x < WIDTH; x++ ) {
			buf[y][x] = ' ';
		}
	}
	FILE *fp = fopen("input-08", "r");
	if ( fp == NULL ) {
		printf("couldn't open file\n");
		exit(1);
	}
	char row[255];
	char command[30];
	int x, y, by;
	char x_or_y;
	while ( fgets(row, 255, fp) ) {
		sscanf(row, "%s ", command);
		if ( strlen(command) == 4 ) {
			sscanf(row+5, "%dx%d", &x, &y);
			rect(buf, x, y);
		} else {
			sscanf(row+7, "%s %c=%d by %d", command, &x_or_y, &x, &by);
			if ( x_or_y == 'x' ) {
				rotate_col(buf, x, by);
			} else {
				rotate_row(buf, x, by);
			}
		}
	}
	fclose(fp);
	int cnt = 0;
	for ( y = 0; y < HEIGHT; y++ ) {
		for ( x = 0; x < WIDTH; x++ ) {
			if ( buf[y][x] == '#' ) {
				cnt++;
			}
		}
	}
	printf("nr pixels lit: %d\n", cnt); 
	draw_screen(buf);
}
