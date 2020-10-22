#include <stdio.h>
#include <stdlib.h>
#include "libs.h"

char* read_file(const char* filename) {
    char* contents = NULL;
    FILE *fp = fopen(filename, "r");
    if ( fp != NULL ) {
        if ( fseek(fp, 0L, SEEK_END) == 0 ) {
            long bufsize = ftell(fp);
            if ( bufsize == -1 ) {
                printf("Failed to get size of the file\n");
                exit(1);
            }
            contents = calloc(bufsize + 1, sizeof(char));
            if ( fseek(fp, 0L, SEEK_SET) != 0 ) {
                free(contents);
                printf("Failed to seek back to the start of the file\n");
                exit(1);
            }
            fread(contents, sizeof(char), bufsize, fp);
            if ( ferror(fp) != 0 ) {
                free(contents);
                printf("Failed to read the file\n");
                exit(1);
            }
        } else {
            printf("Failed to seek to the end of the file\n");
            exit(1);
        }
        fclose(fp);
    } else {
        printf("Failed to open file %s\n", filename);
        exit(1);
    }
    return contents;
}

