#include <stdio.h>
#include <stdlib.h>

int main() {
	FILE* fp = fopen("input-06","r");
	if ( fp == NULL ) {
		printf("couldn't open file\n");
		exit(1);
	}
	char buff[10];
	char freq[8][26] = { {0} };
	while ( fgets(buff,10,fp) ) {
		for ( int i = 0; i<8; i++ ) {
			freq[i][buff[i] - 'a']++;
		}
	}
	fclose(fp);
	int max = 0;
	char max_c = 0;
	for ( int i = 0; i < 8; i++ ) {
		max = 0;
	   	max_c = 0;
		for ( int j = 0; j < 26; j++ ) {
			if ( freq[i][j] > max ) {
				max_c = j + 'a';
				max = freq[i][j];
			}
		}
		printf("%c", max_c);
	}
	printf("\n");
	int min = 0;
	char min_c = 0;
	for ( int i = 0; i < 8; i++ ) {
        min = 0;
        min_c = 0;
        for ( int j = 0; j < 26; j++ ) {
            if ( freq[i][j] > 0 && (freq[i][j] < min || min == 0) ) {
                min_c = j + 'a';
                min = freq[i][j];
            }
        }
        printf("%c", min_c);
    }
    printf("\n");
}
