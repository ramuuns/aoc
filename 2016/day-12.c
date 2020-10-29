#include <stdio.h>
#include <stdlib.h>

typedef struct _memory {
	int reg[4];
	int ip;
} MEMORY;

MEMORY computer;

void cpy(int src, int* tgt) {
	*tgt = src;
	computer.ip++;
}

void jnz(int src, int *offset) {
	//printf("should jump by %d\n", *offset);
	if ( src != 0 ) {
		computer.ip += *offset;
	} else {
		computer.ip += 1;
	}
}

void inc(int whatevs, int *tgt) {
	*tgt += 1;
	computer.ip++;
}

void dec(int whatevs, int *tgt) {
	*tgt -= 1;
	computer.ip++;
}

typedef struct _instruction {
	void (*fn)(int, int*);
	int *arg0;
	int *arg1;
} INSTRUCTION;

INSTRUCTION parse_line(char *str) {
	INSTRUCTION inst;
	char inst_st[4];
	int *nr0 = calloc(1, sizeof(int));
	int *nr = calloc(1, sizeof(int));
	char ch;
	int offset = 0;
	sscanf(str, "%s ", inst_st);
	if ( inst_st[0] == 'c' ) {
		if ( str[4] >= 'a' ) {
			inst.arg0 = &computer.reg[str[4] - 'a'];
			offset = 6;
		} else {
			sscanf(str+4, "%d ", nr);
			offset = 5;
			inst.arg0 = nr;
			for ( int i = 1; *nr / i; i*=10 ) {
				offset++;
			}
		}
		inst.arg1 = &computer.reg[str[offset] - 'a'];
		inst.fn = &cpy;
	} else if ( inst_st[0] == 'j' ) {
		inst.fn = &jnz;
		if ( str[4] >= 'a' ) {
			offset = 6;
			inst.arg0 = &computer.reg[str[4] - 'a'];
		} else {
			sscanf(str+4, "%d", nr0);
			offset = 5;
            inst.arg0 = nr0;
            for ( int i = 1; *nr0 / i; i*=10 ) {
                offset++;
            }
		}
		sscanf(str+offset,"%d", nr);
		inst.arg1 = nr;
	} else if ( inst_st[0] == 'i' ) {
		inst.fn = &inc;
		inst.arg0 = nr;
		inst.arg1 = &computer.reg[str[4] - 'a'];
	} else if ( inst_st[0] == 'd' ) {
		inst.fn = &dec;
		inst.arg0 = nr;
		inst.arg1 = &computer.reg[str[4] - 'a'];
	} else {
		printf("unknown instruction %s\n", inst_st);
	   	exit(1);
	}
	return inst;	
}

int main() {
	FILE *fp = fopen("input-12","r");
	if ( fp == NULL ) {
		printf("cannot open file\n");
		exit(1);
	}
	char buf[30];
	INSTRUCTION program[1000];
	int nr_instructions = 0;
	while (fgets(buf, 30, fp)) {
		program[nr_instructions++] = parse_line(buf);
	}
	fclose(fp);
	computer.reg[0] = 0;
	computer.reg[1] = 0;
	computer.reg[2] = 0;
	computer.reg[3] = 0;
	computer.ip = 0;

	/*
	for ( int i = 0; i < nr_instructions; i++ ) {
		printf("arg0: %d, arg1: %d\n", *program[i].arg0, *program[i].arg1);
	}
*/
	while ( computer.ip < nr_instructions ) {
	//	printf("ip: %d\n", computer.ip);
		(*program[computer.ip].fn)(*program[computer.ip].arg0, program[computer.ip].arg1);
	}
	printf("register at end: %d\n", computer.reg[0]);

	computer.reg[0] = 0;
    computer.reg[1] = 0;
    computer.reg[2] = 1;
    computer.reg[3] = 0;
    computer.ip = 0;

	while ( computer.ip < nr_instructions ) {
    //  printf("ip: %d\n", computer.ip);
        (*program[computer.ip].fn)(*program[computer.ip].arg0, program[computer.ip].arg1);
    }
    printf("register at end: %d\n", computer.reg[0]);
}

