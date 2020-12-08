#include <stdio.h>
#include "_timer.h"


typedef struct _computer {
    int ip;
    int acc;
} computer_t;

typedef struct _instruction_t {
    int arg;
    int seen;
    int changed;
    void (*fn)(int*);
} instruction_t;

computer_t comp;

void noop(int* arg) {
    comp.ip++;
}

void jmp(int *arg) {
    comp.ip += *arg;
}

void acc(int *arg) {
    comp.acc += *arg;
    comp.ip++;
}

int main() {
    timer_start();
    FILE *fp = fopen("input-08","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int program_size;
    comp.ip = 0;
    comp.acc = 0;
    char buff[15];
    while ( fgets(buff, 15, fp) ) {
        if ( buff[0] != '\n' ) {
            program_size++;
        }
    }
    fseek(fp, 0, SEEK_SET);
    instruction_t program[program_size];
    int i = 0;
    char inst[4];
    int n;
    while ( fgets(buff, 15, fp) ) {
        sscanf(buff, "%3s %d", inst, &n);
        program[i].arg = n;
        program[i].seen = 0;
        program[i].changed = 0;
        switch ( inst[0] ) {
            case 'n':
                program[i].fn = &noop;
                break;
            case 'j':
                program[i].fn = &jmp;
                break;
            case 'a':
                program[i].fn = &acc;
                break;
            default:
                printf("unknown instruction found on line %d (%s)\n", i, buff);
                return 1;
        }
        i++;
    }
    while ( 1 ) {
        if ( program[comp.ip].seen ) {
            break;
        }
        program[comp.ip].seen = 1;
        (*program[comp.ip].fn)(&program[comp.ip].arg);
    }
    printf("acc after one loop: %d\n", comp.acc);
    int did_exit_cleanly = 0;
    int changed_instr = -1;
    while ( 1 ) {
        comp.ip = 0;
        comp.acc = 0;
        int did_change = 0;
        if ( changed_instr >= 0 ) {
            program[changed_instr].fn = program[changed_instr].fn == &noop ? &jmp : &noop;
        }
        for ( int i = 0; i < program_size; i++ ) {
            program[i].seen = 0;
        }
        while ( 1 ) {
            if ( comp.ip >= program_size ) {
                did_exit_cleanly = 1;
                break;
            }
            if ( program[comp.ip].seen ) {
                break;
            }
            if ( !did_change && !program[comp.ip].changed && program[comp.ip].fn != &acc ) {
                did_change = 1;
                changed_instr = comp.ip;
                program[comp.ip].changed = 1;
                program[comp.ip].fn = program[comp.ip].fn == &noop ? &jmp : &noop;
            }
            program[comp.ip].seen = 1;
            (*program[comp.ip].fn)(&program[comp.ip].arg);
        }
        if ( did_exit_cleanly ) {
            break;
        }
    }
    printf("acc after fixing the software: %d\n", comp.acc);
    printtime();
}
