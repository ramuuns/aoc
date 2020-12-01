#include <stdio.h>


int main() {
    FILE *fp = fopen("input-01","r");
    if ( !fp ) {
        printf("could not open file\n");
        return 1;
    }
    char buff[255];
    int data[255];
    int nr_rows = 0;
    while (fgets(buff, 255, fp) ) {
        sscanf(buff, "%d", &data[nr_rows]);
        nr_rows++;
    }

    int a, b;
    for ( int i = 0; i < nr_rows; i++ ) {
        for ( int j = i; j < nr_rows; j++ ) {
            if (data[i] + data[j] == 2020 ) {
                a = data[i];
                b = data[j];
                break;
            }
        }
    }
    printf("a*b = %d\n", a*b);
    int c;
    for ( int i = 0; i < nr_rows; i++ ) {
        for ( int j = i; j < nr_rows; j++ ) {
            for ( int k = j; k < nr_rows; k++ ) {
                if ( data[i] + data[j] + data[k] == 2020 ) {
                    a = data[i];
                    b = data[j];
                    c = data[k];
                    break;
                }
            }
        }
    }
    printf("a*b*c = %d\n", a*b*c); 
}
