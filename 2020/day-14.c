#include <stdio.h>
#include <stdlib.h>
#include "_timer.h"

int main(){
    timer_start();
    FILE *fp = fopen("input-14","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[255];
    unsigned long memory[500][2] = { {0,0} };
    unsigned long *memoryp2 = calloc((unsigned long)1<<36, sizeof(unsigned long));
    int memsize = 0;
    unsigned long *memstack[100000] = { NULL };
    int memsize2 = 0;
    unsigned long value, onemask = 0, zeromask = 0;
    unsigned long addrmasks[512][2];
    int addrmask_cnt = 0;
    int addr;
    while ( fgets(buff, 255, fp) ) {
        if (buff[0] == '\n' ) {
            continue;
        }
        if ( buff[1] == 'a' ) { //mask = X10X
            onemask = 0;
            zeromask = 0;
            int i = 7;
            addrmasks[0][0] = 0;
            addrmasks[0][1] = 0;
            addrmask_cnt = 1;
            while ( buff[i] != '\n' ) {
                onemask <<= 1;
                zeromask <<= 1;
                for ( int k = 0; k < addrmask_cnt; k++ ) {
                    addrmasks[k][0] <<= 1;
                    addrmasks[k][1] <<= 1;
                }
                if ( buff[i] == '1' ) {
                    onemask |= 1;
                }
                if ( buff[i] == '0' ) {
                    zeromask |= 1;
                }
                if ( buff[i] == 'X' ) {
                    for ( int k = 0; k < addrmask_cnt; k++ ) {
                        addrmasks[k+addrmask_cnt][0] = addrmasks[k][0];
                        addrmasks[k+addrmask_cnt][1] = addrmasks[k][1];
                        addrmasks[k+addrmask_cnt][1] |= 1;
                        addrmasks[k][0] |= 1;
                    }
                    addrmask_cnt <<= 1;
                }
                i++;
            }
        } else { //mem[234] = 456
            sscanf(buff, "mem[%d] = %lu", &addr, &value);
            int i = 0;
            while ( i < memsize && memory[i][0] != addr ) {
                i++;
            }
            memory[i][0] = addr;
            memory[i][1] = (value | onemask) & ~zeromask;
            if ( i == memsize ) {
                memsize++;
            }
            for ( int k = 0; k < addrmask_cnt; k++ ) {
                unsigned long addr2 = ((addr | onemask) | addrmasks[k][1] ) & ~(addrmasks[k][0] );
                *(memoryp2+addr2) = value;
                memstack[memsize2++] = memoryp2+addr2;
            }
        }
    }
    fclose(fp);
    unsigned long sum = 0;
    for ( int i = 0; i < memsize; i++ ) {
        sum += memory[i][1];
    }
    printf("sum: %lu\n", sum);
    sum = 0;
    for ( int i = memsize2-1; i >= 0; i-- ) {
        sum += *(memstack[i]);
        *(memstack[i]) = 0;
        
    }
    printf("sump2: %lu (memsize: %d)\n", sum, memsize2);
    free(memoryp2);
    printtime();
}
