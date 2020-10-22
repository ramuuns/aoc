#include <stdio.h>
#include <stdlib.h>

int main() {
	FILE* fp = fopen("input-03", "r");
	if ( fp == NULL ) {
		printf("couldn't open file for reading\n");
		exit(1);
	}
	char buffer[1024];
	unsigned int a = 0;
	unsigned int b = 0;
	unsigned int c = 0;
	int legit_triangles = 0;
	while ( fgets(buffer, 1024, fp) ) {
		if ( sscanf(buffer, " %u %u %u", &a, &b, &c) == 3 ) {
			if ( a + b > c && a + c > b && b + c > a ) {
				legit_triangles++;
			}
		}
	}
	printf("Legit triangles: %d\n", legit_triangles);

	unsigned int aa[3][3] = { { 0, 0, 0 }, {0,0,0}, {0,0,0} };
	int n = 0;
	legit_triangles = 0;
	if ( fseek(fp, 0, SEEK_SET) != 0 ) {
		printf("coulnd't restart from the top\n");
		exit(1);
	}
	while ( fgets(buffer, 1024, fp) ) {
        if ( sscanf(buffer, " %u %u %u", &aa[0][n], &aa[1][n], &aa[2][n]) == 3 ) {
			n++;
        }
		if (n == 3) {
			for ( int i = 0; i < 3; i++ ) {
				if ( aa[i][0] + aa[i][1] > aa[i][2] && aa[i][0] + aa[i][2] > aa[i][1] && aa[i][1] + aa[i][2] > aa[i][0] ) {
					legit_triangles++;
				}
			}	
			n = 0;
		}
    }
	fclose(fp);
    printf("Legit triangles (columns): %d\n", legit_triangles);
}

