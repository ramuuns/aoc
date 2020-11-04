#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LENGTH 8

#define SCRAMBLED "fbgdceah"

void swap_position(char *str, int x, int y) {
    char c = str[x];
    str[x] = str[y];
    str[y] = c;
}

void swap_letter(char *str, char a, char b) {
    for ( int i = 0; i < LENGTH; i++ ) {
        if ( str[i] == a ) {
            str[i] = b;
        } else if ( str[i] == b ) {
            str[i] = a;
        }
    }
}

void rotate(char *str, int dir, int steps) {
    char tmp[LENGTH];
    memcpy(tmp, str, LENGTH);
    for ( int i = 0; i < LENGTH; i++ ) {
        str[i] = tmp[ ( 2*LENGTH + i - steps*dir ) % LENGTH ];
    }
}

void rotate_based(char *str, char a) {
    int idx_of_a = 0;
    while ( str[idx_of_a] != a ) {
        idx_of_a++;
    }
    int rot = 1 + idx_of_a + (idx_of_a >= 4 ? 1 : 0);
    rotate(str, 1, rot);
}

void rotate_based_rev(char* str, char a) {
    int rot = 1;
    rotate(str, -1, 1);
    int idx_of_a = 0;
    while ( str[idx_of_a] != a ) {
        idx_of_a++;
    }
    while ( rot != 1 + idx_of_a + ( idx_of_a >= 4 ? 1 : 0 ) ) {
        rotate(str, -1, 1);
        rot++;
        idx_of_a = (idx_of_a + LENGTH - 1 ) % LENGTH;
    }
}

void reverse(char *str, int x, int y) {
    char tmp;
    for ( ; x < y; x++, y-- ) {
        swap_position(str, x, y);
    }
}

void move(char *str, int x, int y) {
    char tmp = str[x];
    if ( x < y ) {
        for ( int i = x; i < y; i++ ) {
            str[i] = str[i+1];
        }
    } else {
        for ( int i = x; i > y; i-- ) {
            str[i] = str[i-1];
        }
    }
    str[y] = tmp;
}

void print(char *str) {
    for ( int i =0; i < LENGTH; i++ ){ 
        printf("%c", str[i]);
    }
    printf("\n");
}

int main() {
    char str[LENGTH];
    for ( int i = 0; i < LENGTH; i++ ){
       str[i] = i+'a';
    }
    FILE *fp = fopen("input-21", "r");
    if ( !fp ) {
        printf("no file\n");
        exit(1);
    }
    char lines[100][255];
    char buff[255];
    char a, b;
    int x,y;
    int l = 0;
    while ( fgets(buff, 255, fp) ) {
        //printf("%s\n", str);
        memcpy(lines[l++], buff, strlen(buff));
        //print(str);
        if ( buff[0] == 's' && buff[5] == 'p' ) { //swap position
            sscanf(buff, "swap position %d with position %d", &x, &y);
            swap_position(str, x, y);
        } else if ( buff[0] == 's' && buff[5] == 'l' ) {
            sscanf(buff, "swap letter %c with letter %c", &a, &b);
            swap_letter(str, a, b);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'b' ) {
            sscanf(buff, "rotate based on position of letter %c", &a);
            rotate_based(str, a);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'l' ) {
            sscanf(buff, "rotate left %d step", &x);
            rotate(str, -1, x);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'r' ) {
            sscanf(buff, "rotate right %d step", &x);
            rotate(str, 1, x);
        } else if ( buff[0] == 'r' && buff[1] == 'e' ) {
            sscanf(buff, "reverse positions %d through %d", &x, &y);
            reverse(str, x, y);
        } else if ( buff[0] == 'm' ) {
            sscanf(buff, "move position %d to position %d", &x, &y);
            move(str, x, y);
        } else {
            printf("hmm, I cannot parse %s\n", buff);
        }
    }
    fclose(fp);
    printf("scrambled password: ");
    print(str);

    char *scrambled = SCRAMBLED;
    for ( int i = 0; i < LENGTH; i++ ) {
        str[i] = scrambled[i];
    }

    for ( int i = 99; i >= 0; i-- ) {
        memcpy(buff, lines[i], strlen(lines[i]));
        //print(str);
        if ( buff[0] == 's' && buff[5] == 'p' ) { //swap position
            sscanf(buff, "swap position %d with position %d", &x, &y);
            swap_position(str, x, y);
        } else if ( buff[0] == 's' && buff[5] == 'l' ) {
            sscanf(buff, "swap letter %c with letter %c", &a, &b);
            swap_letter(str, b, a);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'b' ) {
            sscanf(buff, "rotate based on position of letter %c", &a);
            rotate_based_rev(str, a);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'l' ) {
            sscanf(buff, "rotate left %d step", &x);
            rotate(str, 1, x);
        } else if ( buff[0] == 'r' && buff[1] == 'o' && buff[7] == 'r' ) {
            sscanf(buff, "rotate right %d step", &x);
            rotate(str, -1, x);
        } else if ( buff[0] == 'r' && buff[1] == 'e' ) {
            sscanf(buff, "reverse positions %d through %d", &x, &y);
            reverse(str, x, y);
        } else if ( buff[0] == 'm' ) {
            sscanf(buff, "move position %d to position %d", &x, &y);
            move(str, y, x);
        } else {
            printf("hmm, I cannot parse %s\n", buff);
        }
    }

    printf("unscrambled password: ");
    print(str);
    //printf("scrambled password: %s\n", str);
}
