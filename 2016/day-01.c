#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libs.h"

typedef struct _dir {
	int x;
	int y;
} Dir;

typedef struct _line {
	Dir start;
	Dir end;
} Line;

int min(int x, int y) {
	return x < y ? x: y;
}

int max(int x, int y) {
	return x > y ? x :y;
}	

int lines_intersect(Line a, Line b) {
	if ( a.start.x == a.end.x && b.start.x == b.end.x ) {
		return 0;
	} else if ( a.start.y == a.end.y && b.start.y == b.end.y ) {
		return 0;
	}
	if ( a.start.x == a.end.x ) {
		if ( a.start.x >= min(b.start.x, b.end.x) && a.start.x <= max(b.start.x, b.end.x) &&
			 b.start.y >= min(a.start.y, a.end.y) && b.start.y <= max(a.start.y, a.end.y) ) {
			return 1;
		} else {
			return 0;
		}
	} else {
		if ( a.start.y >= min(b.start.y, b.end.y) && a.start.y <= max(b.start.y, b.end.y) &&
             b.start.x >= min(a.start.x, a.end.x) && b.start.x <= max(a.start.x, a.end.x) ) {
            return 1;
        } else {
            return 0;
        }
	}
}

Dir intersection(Line a, Line b) {
	Dir ret = {0,0};
	if ( a.start.x == a.end.x ) {
		ret.x = a.start.x;
		ret.y = b.start.y;
	} else {
		ret.x = b.start.x;
		ret.y = a.start.y;
	}
	return ret;
}

int main() {
	char* data_as_string = read_file("input-01");
	int x = 0;
	int y = 0;
	Dir dir = { 0, 1 };
	int n = 0;
	size_t l = strlen(data_as_string);
	Line* lines  = malloc(sizeof(Line) * l);
	int nr_lines = 0;
	int seen_twice = 0;
	int old_x = 0;
	Dir location_seen_twice = {0, 0};
	int prevx = 0;
	int prevy = 0;
	for ( int i = 0; i < l; i++ ) {
		switch ( data_as_string[i] ) {
			case 'L':
				old_x = dir.x;
				dir.x = dir.x != 0 ? 0 : ( dir.y == 1 ? -1 : 1 );
				dir.y = dir.y != 0 ? 0 : ( old_x == 1 ? 1 : -1 );
//				printf("Turned left, new dir: x: %d, y:%d\n", dir.x, dir.y);
				break;
			case 'R':
				old_x = dir.x;
				dir.x = dir.x != 0 ? 0 : ( dir.y == 1 ? 1 : -1 );
				dir.y = dir.y != 0 ? 0 : ( old_x == 1 ? -1 : 1 );
//				printf("Turned right, new dir: x: %d, y:%d\n", dir.x, dir.y);
				break;
			case ',':
				prevx = x;
				prevy = y;
				x += dir.x * n;
				y += dir.y * n;
				if ( !seen_twice ) {
					lines[nr_lines].start.x = prevx;
					lines[nr_lines].start.y = prevy;
					lines[nr_lines].end.x = x;
					lines[nr_lines].end.y = y;
					for ( int j = 0; j < nr_lines - 1; j++ ) {
						if ( lines_intersect(lines[j], lines[nr_lines]) ) {
							seen_twice = 1;
							location_seen_twice = intersection(lines[j], lines[nr_lines]);
							break;
						}
					}
					nr_lines++;
				}
//				printf("Moved %d places, now at x:%d.y:%d\n", n, x,y);
				n = 0;
				break;
			default:
				if ( data_as_string[i] >= '0' && data_as_string[i] <= '9' ) {
					n = n*10 + (data_as_string[i] - '0');
//					printf("Now n is : %d\n", n);
				}
				break;
		}
	}
	if ( n != 0 ) {
		prevx = x;
		prevy = y;
		x += dir.x * n;
		y += dir.y * n;
		if ( !seen_twice ) {
			lines[nr_lines].start.x = prevx;
			lines[nr_lines].start.y = prevy;
			lines[nr_lines].end.x = x;
			lines[nr_lines].end.y = y;
			for ( int j = 0; j < nr_lines; j++ ) {
				if ( lines_intersect(lines[j], lines[nr_lines]) ) {
					seen_twice = 1;
					location_seen_twice = intersection(lines[j], lines[nr_lines]);
					break;
				}
			}
			nr_lines++;
		}
//		printf("Moved %d places, now at x:%d.y:%d\n", n, x,y);
	}
	printf("X: %d, Y: %d\ndistance: %d\n", x, y, abs(x)+abs(y));
	printf("twice seen: x: %d, y:%d\ndistance %d\n", location_seen_twice.x, location_seen_twice.y, abs(location_seen_twice.x)+abs(location_seen_twice.y));
	free(lines);
	free(data_as_string);
}

