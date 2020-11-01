#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/md5.h>

#define SALT "cuanljph"
//#define SALT "abc"

#define LOW_MASK 0x0F

typedef struct _indexes {
    unsigned int idx;
    struct _indexes *next;
} Indexes;

typedef struct _idx_row {
    Indexes *start;
    Indexes *end;
} IndexRow;

void push_index(IndexRow* row, unsigned int idx) {
    if ( row->end != NULL && row->end->idx == idx ) {
        return;
    }
    Indexes *new = malloc(sizeof(Indexes));
    new->idx = idx;
    new->next = NULL;
    if ( row->start == NULL ) {
        row->start = new;
        row->end = new;
        return;
    }
    row->end->next = new;
    row->end = new;
}

char has_good_index(IndexRow* row, unsigned int idx) {
    Indexes *curr = row->start;
//    printf("checking if there is a good index \n");
    while ( curr != NULL && curr->idx != idx ) {
//        printf("comparing %u with %u\n", idx, curr->idx);
        if ( idx < 1000 || curr->idx > idx - 1000 ) {
            return 1;
        }
        row->start = row->start->next;
        free(curr);
        curr = row->start;
    }
    if ( row->start == NULL ) {
        row->end = NULL;
    }
    return 0;
}

unsigned int get_index(IndexRow* row) {
    unsigned int ret = row->start->idx;
    Indexes *curr = row->start;
    row->start = row->start->next;
    free(curr);
    return ret;
}

int char_to_half_char(unsigned char c, int idx) {
    if ( idx%2 == 0 ) {
        return c >> 4;
    }
    return c & LOW_MASK;
}

unsigned int max(unsigned int a, unsigned int b){ 
    return a > b ? a : b;
}

void multihash(char* str, unsigned char* hash) {
    MD5((unsigned char*)str, strlen(str), hash);
    int c;
    for ( int i = 0; i < 2016; i++ ) {
        for ( int j = 0; j < MD5_DIGEST_LENGTH*2; j++ ) {
            c = j % 2 == 0 ? hash[j/2] >> 4 : hash[j/2] & LOW_MASK;
            str[j] = c < 10 ? '0' + c : 'a' + c - 10;
        }
        str[MD5_DIGEST_LENGTH*2] = 0;
        MD5((unsigned char*)str, MD5_DIGEST_LENGTH*2, hash);
    }
}

int main() {
    IndexRow* indexes[16];
    for ( int i = 0; i < 16; i++ ) {
        indexes[i] = malloc(sizeof(IndexRow));
        indexes[i]->start = NULL;
        indexes[i]->end = NULL;
    }

    unsigned char hash[MD5_DIGEST_LENGTH];
    char str[255];
    unsigned int idx = 0;
    unsigned int last_good_index = 0;
    unsigned int found_indexes = 0;
    unsigned int last_idx;
    int thisc;
    int print_this_hash = 0;
    int _has_triplet = 0;
    while ( found_indexes < 64 ) {
        sprintf(str, SALT"%u", idx);
        MD5((unsigned char*)str, strlen(str), hash);
        print_this_hash = 0;
        _has_triplet = 0;
        for ( int i = 0; i < MD5_DIGEST_LENGTH*2; i ++ ) {
            thisc = char_to_half_char(hash[i/2], i);
            if ( ! _has_triplet && i >= 2 && thisc == char_to_half_char(hash[(i-2)/2], i-2) && thisc == char_to_half_char(hash[(i-1)/2], i-1) ) {
                //printf("candidate index %u for %x\n", idx, thisc);
                push_index(indexes[thisc], idx);
                _has_triplet = 1;
            }
            if ( i >= 4
                && thisc == char_to_half_char(hash[(i-4)/2], i-4)
                && thisc == char_to_half_char(hash[(i-3)/2], i-3)
                && thisc == char_to_half_char(hash[(i-2)/2], i-2)
                && thisc == char_to_half_char(hash[(i-1)/2], i-1) ) {
                while ( has_good_index(indexes[thisc], idx) ) {
                    last_idx = get_index(indexes[thisc]);
                    last_good_index = max(last_idx, last_good_index);
                    found_indexes++;
                    printf("Index %u for %x found at %u (%u)\n", found_indexes, thisc, last_idx, idx);
                }
            }
        }
        if ( 0 && print_this_hash ) {
            for ( int i = 0; i < MD5_DIGEST_LENGTH; i++ ) {
                printf("%x", hash[i]);
            }
            printf("\n");
        }
        idx++;
    }
    printf("last good index: %u\n", last_good_index);

    for ( int i = 0; i < 16; i++ ) {
        has_good_index(indexes[i], last_good_index + 100000);
    }
    found_indexes = 0;
    last_good_index = 0;
    int all_checked = 1000;
    idx = 0;
    while ( found_indexes < 64 && all_checked > 0 ) {
        sprintf(str, SALT"%u", idx);
        multihash(str, hash);
        print_this_hash = 0;
        _has_triplet = 0;
        for ( int i = 0; i < MD5_DIGEST_LENGTH*2; i ++ ) {
            thisc = char_to_half_char(hash[i/2], i);
            if ( !_has_triplet && i >= 2 && thisc == char_to_half_char(hash[(i-2)/2], i-2) && thisc == char_to_half_char(hash[(i-1)/2], i-1) ) {
                //printf("candidate index %u for %x\n", idx, thisc);
                push_index(indexes[thisc], idx);
                print_this_hash = 1;
                _has_triplet = 1;
            }
            if ( i >= 4
                && thisc == char_to_half_char(hash[(i-4)/2], i-4)
                && thisc == char_to_half_char(hash[(i-3)/2], i-3)
                && thisc == char_to_half_char(hash[(i-2)/2], i-2)
                && thisc == char_to_half_char(hash[(i-1)/2], i-1) ) {
                while ( has_good_index(indexes[thisc], idx) ) {
                    last_idx = get_index(indexes[thisc]);
                    last_good_index = max(last_idx, last_good_index);
                    found_indexes++;
                    if ( found_indexes == 64 ) {
                        all_checked = 1000 - (idx - last_idx);
                    }
                    printf("Index %u for %x found at %u (%u)\n", found_indexes, thisc, last_idx, idx);
                }
            }
        }
        if ( 0 && print_this_hash ) {
            for ( int i = 0; i < MD5_DIGEST_LENGTH; i++ ) {
                printf("%x", hash[i]);
            }
            printf("\n");
        }
        idx++;
        if ( found_indexes > 64 ) {
            all_checked--;
        }
    }
    printf("last good index: %u\n", last_good_index);
}

