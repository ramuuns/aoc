#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void calc_checksum(char* char_count, char* checksum) {
	for ( int i = 0; i < 26; i++) {
		if ( char_count[i] ) {
			for ( int j = 0; j < 5; j++ ) {
				if ( checksum[j] ) {
					if ( char_count[checksum[j] - 'a'] < char_count[i] ) {
						for ( int k = 3; k >= j; k-- ) {
							checksum[k+1] = checksum[k];
						}
						checksum[j] = 'a' + i;
						break;
					} else {
						continue;
					}
				} else {
					checksum[j] = 'a' + i;
					break;
				}
			}
		}
	}
}

void print_map(char* char_count) {
	for ( int i = 0; i < 26; i++ ) {
		if ( char_count[i] ) {
			printf("%c : %d, ", 'a' + i, char_count[i]);
		}
	}
	printf("\n");
}

void print_room_name(char* buffer, int sector_id) {
	int delta = sector_id % 26;
	int l = strlen(buffer);
	for ( int i = 0; i < l; i++ ) {
		if ( buffer[i] >= 'a' && buffer[i] <= 'z' ) {
			printf("%c", (((buffer[i] - 'a') + delta ) % 26) + 'a');
		} else if ( buffer[i] == '-' ) {
			printf(" ");
		} else if ( buffer[i] >= '0' && buffer[i] <= '9' ) {
			printf("%d\n", sector_id);
			break;
		}
	}
}

int main() {
	FILE* fp = fopen("input-04", "r");
	if ( fp == NULL ) {
		printf("couldn't open file\n");
		exit(1);
	}
	char buffer[255];
	char char_count[26];
	int validating_checksum = 0;
	int sector_id = 0;
	int sector_id_sum = 0;
	int checksum_is_valid = 1;
	char checksum[5];
	int checksum_ptr = 0;
	while ( fgets(buffer, 255, fp) ) {
		memset(char_count, 0, sizeof char_count);
		memset(checksum, 0, sizeof checksum);
		sector_id = 0;
		checksum_is_valid = 1;
		checksum_ptr = 0;
		validating_checksum = 0;
		for ( int i = 0; buffer[i]; i++ ) {
			if ( buffer[i] == '-' || buffer[i] == '\n' ) {
				continue;
			}
			if ( buffer[i] == '[' ) {
				validating_checksum = 1;
				calc_checksum(char_count, checksum);
//				printf("buffer: %s, checksum: %s\n", buffer, checksum);
//				print_map(char_count);
				continue;
			}
			if ( buffer[i] >= '0' && buffer[i] <= '9' ) {
				sector_id = sector_id * 10 + ( buffer[i] - '0' );
				continue;
			}
			if ( buffer[i] >= 'a' && buffer[i] <= 'z' ) {
				if ( validating_checksum ) {
					if ( buffer[i] != checksum[checksum_ptr] ) {
						checksum_is_valid = 0;
						break;
					} else {
						checksum_ptr++;
					}
				} else {
					char_count[buffer[i] - 'a']++;
				}
				continue;
			}
			if ( buffer[i] == ']' ) {
				if ( checksum_is_valid ) {
					sector_id_sum += sector_id;
					print_room_name(buffer, sector_id);
				}
				continue;
			}
			printf("found an invalid character %c\n", buffer[i]);
		   	exit(1);	
		}
	}
	fclose(fp);
	printf("sum of all of the legit sector_ids: %d\n", sector_id_sum);
}
