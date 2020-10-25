#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
	FILE *fp = fopen("input-07","r");
	if ( fp == NULL ) {
		printf("couldn't open the input file\n");
		exit(1);
	}
	char buffer[255];
	int count = 0;
	int has_abba = 0;
	int in_hypernet = 0;
	int has_abba_in_hypernet = 0;
	int l = 0;

	while (fgets(buffer, 255, fp)) {
		has_abba = 0;
		in_hypernet = 0;
		has_abba_in_hypernet = 0;
		l = strlen(buffer);
		for ( int i = 0; i < l; i++ ) {
			if ( buffer[i] == '[' ) {
				in_hypernet = 1;
			} else if ( buffer[i] == ']' ) {
				in_hypernet = 0;
			} else if ( i >= 3 ) {
				if ( buffer[i - 3] == buffer[i] && buffer[i-2] == buffer[i-1] && buffer[i-1] != buffer[i] ) {
					if ( in_hypernet ) {
						has_abba_in_hypernet = 1;
					} else {
						has_abba = 1;
					}
				}	
			}	
		}
		if ( has_abba && !has_abba_in_hypernet ) {
			count++;
		}
	}
	if ( fseek(fp,0,SEEK_SET) != 0 ) {
		fclose(fp);
		printf("could't go back to the start\n");
		exit(1);
	}
	int ssl_count;
	char trigrams[676];
	char hypernet_trigrams[676];
	int key = 0;
	while (fgets(buffer, 255, fp)) {
		memset(trigrams, 0, sizeof(char) * 676);
		memset(hypernet_trigrams, 0, sizeof(char) * 676);
		in_hypernet = 0;
		l = strlen(buffer);
		for ( int i = 0; i < l; i++ ) {
			if ( buffer[i] == '[' ) {
                in_hypernet = 1;
            } else if ( buffer[i] == ']' ) {
                in_hypernet = 0;
            } else if ( i >= 2 ) {
				if ( buffer[i-2] == buffer[i] && buffer[i] != buffer[i-1] && buffer[i-1] != '[' && buffer[i-1] != ']' ) {
					if ( in_hypernet ) {
						key = (buffer[i-1] - 'a') * 26 + ( buffer[i] - 'a' );
						hypernet_trigrams[key]++;
					} else {
						key = (buffer[i] - 'a') * 26 + ( buffer[i-1] - 'a' );
						trigrams[key]++;
					}
					if ( trigrams[key] > 0 && hypernet_trigrams[key] > 0 ) {
/*						printf("buffer:\n%s",buffer);
					    for ( int k = 0; k < i - 2; k++ ) { printf(" "); }
						printf("%c%c%c\n", buffer[i-2], buffer[i-1], buffer[i]);
						printf("known trigrams: ");
						for ( int k = 0; k < 676; k++ ) {
							if ( trigrams[k] > 0 ) {
								printf("%c%c%c ", (k / 26) + 'a', (k % 26) + 'a', (k/26) + 'a');
							}
						}
						printf("\nknown reverse trigrams: ");
					    for ( int k = 0; k < 676; k++ ){
							if ( hypernet_trigrams[k] > 0 ) {
                                printf("%c%c%c ", (k % 26) + 'a', (k / 26) + 'a', (k % 26) + 'a');
                            }
						}
						printf("\n"); */
						ssl_count++;
						break;
					}
				}
			}
		}
	}
	fclose(fp);
	printf("TLS network count: %d\n", count);
	printf("SSL network count: %d\n", ssl_count);
}
