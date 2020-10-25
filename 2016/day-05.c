#include <stdio.h>
#include <string.h>
#include <openssl/md5.h>

int main(){
	unsigned char hash[MD5_DIGEST_LENGTH];
	char str[255];
	char pw_i = 0;
	unsigned long i = 0;
  	while ( pw_i < 8 ) {
		sprintf(str, "ojvtpuvg%lu", i);
		MD5((unsigned char*)str, strlen(str), hash);
        if ( hash[0] == 0 && hash[1] == 0 && (hash[2] & 0xF0) == 0 ) {
			printf("%x", hash[2] );
			pw_i++;
		}
		i++;
	}
	printf("\n");
	char pwd[8] = { 16, 16, 16, 16, 16, 16, 16, 16 };
	i = 0;
	pw_i = 0;
	while ( pw_i < 8 ) {
		sprintf(str, "ojvtpuvg%lu", i);
		MD5((unsigned char*)str, strlen(str), hash);
		if ( hash[0] == 0 && hash[1] == 0 && (hash[2] & 0xF0) == 0 ) {
//			printf("%s %d %x\n", str, hash[2], hash[3] >> 4);
			if ( hash[2] < 8 && pwd[hash[2]] == 16 ) {
				pwd[hash[2]] = hash[3] >> 4;
				pw_i++;
				for ( i = 0; i < 8; i++ ) {
					if ( pwd[i] != 16 ) {
						printf("%x", pwd[i] );
					} else {
						printf("_");
					}
				}
				printf("\n");
			}
		}
		i++;
	}
}
