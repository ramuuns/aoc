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
    int memsize2 = 0;
    unsigned long value, onemask = 0, zeromask = 0;
    unsigned long addrmasks[512][2];
    int addrmask_cnt = 0;
    unsigned long addr;
    long sum = 0;
    long sum2 = 0;
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
            sscanf(buff, "mem[%lu] = %lu", &addr, &value);
            int i = 0;
            while ( i < memsize && memory[i][0] != addr ) {
                i++;
            }
            memory[i][0] = addr;
            sum -= memory[i][1];
            memory[i][1] = (value | onemask) & ~zeromask;
            sum += memory[i][1];
            if ( i == memsize ) {
                memsize++;
            }
            addr |= onemask;
            for ( int k = 0; k < addrmask_cnt; k++ ) {
                unsigned long addr2 = (addr | addrmasks[k][1] ) & ~(addrmasks[k][0] );
                sum2 += value - memoryp2[addr2];
                memoryp2[addr2] = value;
            }
        }
    }
    fclose(fp);
    printf("sum: %ld\n", sum);
    printf("sump2: %ld (memsize: %d)\n", sum2, memsize2);
    free(memoryp2);
    printtime();
}
