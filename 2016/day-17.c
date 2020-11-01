#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/md5.h>

#define PASSCODE "pvhmgsws"

#define DIR_TO_X(d) ((d == 'U' || d == 'D') ? 0 : ( d == 'L' ? -1 : 1 ))
#define DIR_TO_Y(d) ((d == 'L' || d == 'R') ? 0 : ( d == 'U' ? -1 : 1 ))


typedef struct _deq {
    int x;
    int y;
    int l;
    char* path;
    struct _deq* next;
} deq;

deq* push_back(deq* qend, int x, int y, char* path, char dir) {
    deq* new = malloc(sizeof(deq));
    new->x = x;
    new->y = y;
    int l = strlen(path);
    new->path = malloc((l+2) * sizeof(char));
    memcpy(new->path, path, l);
    new->l = l + 1;
    new->path[l] = dir;
    new->path[l+1] = 0;
    new->next = NULL;
    qend->next = new;
    return new;
}

void directions(char ret[4], char* path) {
    char *str = malloc(strlen(path) + strlen(PASSCODE) + 1);
    sprintf(str, PASSCODE"%s", path);
    unsigned char hash[MD5_DIGEST_LENGTH];
    MD5((unsigned char*)str, strlen(str), hash);
    ret[0] = (hash[0] >> 4) > 0xA ? 'U' : 0;
    ret[1] = (hash[0] & 0x0F) > 0xA ? 'D' : 0;
    ret[2] = (hash[1] >> 4) > 0xA ? 'L' : 0;
    ret[3] = (hash[1] & 0x0F) > 0xA ? 'R' : 0;
}

int main() {
    deq* curr, *end, *tmp;
    curr = malloc(sizeof(deq));
    curr->x = 0;
    curr->l = 0;
    curr->y = 0;
    char *start_path = calloc(1,1);
    curr->path = start_path;
    curr->next = NULL;
    end = curr;
    char dirs[4];
    int newx;
    int newy;
    int maxl = 0;
    while ( curr ) {
//        printf("x: %d, y: %d  path: %s\n", curr->x, curr->y, curr->path);
        if ( curr->x == 3 && curr->y == 3 ) {
            if ( maxl == 0 ) {
                printf("the good path: %s\n", curr->path);
                maxl = curr->l;
            } else {
                maxl = curr->l > maxl ? curr->l : maxl;
            }
            tmp = curr;
            curr = curr->next;
            free(tmp->path);
            free(tmp);
            continue;
        }
        directions(dirs, curr->path);
        for ( int i = 0; i < 4; i++ ) {
            if ( dirs[i] ) {
                newx = curr->x + DIR_TO_X(dirs[i]);
                newy = curr->y + DIR_TO_Y(dirs[i]);
                if ( newx < 0 || newx > 3 || newy < 0 || newy > 3 ) {
                    continue;
                }
                end = push_back(end, newx, newy, curr->path, dirs[i]);
            }
        }
        tmp = curr;
        curr = curr->next;
        free(tmp->path);
        free(tmp);
    }
    printf("longest path: %d\n", maxl);
    //I mean I guess I should clean up...
    while ( curr ) {
        tmp = curr;
        curr = curr->next;
        free(tmp->path);
        free(tmp);
    }
}
