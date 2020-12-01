#include <stdio.h>
#include <stdlib.h>

typedef struct _memory {
	int reg[4];
	int ip;
    int expected_out;
    int good_outs;
} MEMORY;

MEMORY computer;

int nr_instructions = 0;

#define GOOD_OUTS_TO_CHECK 10000

typedef struct _instruction {
	void (*fn)(struct _instruction*, int, int*);
	int *arg0;
	int *arg1;
} INSTRUCTION;

void cpy(INSTRUCTION *program, int src, int* tgt) {
    if ( tgt == &computer.reg[0] || tgt == &computer.reg[1] || tgt == &computer.reg[2] || tgt == &computer.reg[3] ) {
	    *tgt = src;
    }
	computer.ip++;
}

void jnz(INSTRUCTION *program, int src, int *offset) {
	if ( src != 0 ) {
        if ( *offset == 0 ) {
            computer.ip += 1;   
        } else {
            computer.ip += *offset;
        }
	} else {
		computer.ip += 1;
	}
}

void inc(INSTRUCTION* program, int whatevs, int *tgt) {
	*tgt += 1;
	computer.ip++;
}

void dec(INSTRUCTION* program, int whatevs, int *tgt) {
	*tgt -= 1;
	computer.ip++;
}

void tgl(INSTRUCTION* program, int whatevs, int *tgt) {
    if ( computer.ip + *tgt < 0 || computer.ip + *tgt >= nr_instructions ) {
        computer.ip++;
        return;
        //printf("attempting to toggle an instruction outside the program range %d\n", computer.ip + *tgt);
        //exit(1);
    }
    void *src_fn = program[computer.ip + *tgt].fn;
    if ( src_fn == &inc ) {
        program[computer.ip + *tgt].fn = &dec;
    } else if ( src_fn == &dec || src_fn == &tgl ) {
        program[computer.ip + *tgt].fn = &inc;
    } else if ( src_fn == &cpy ) {
        program[computer.ip + *tgt].fn = &jnz;
    } else if ( src_fn == &jnz ) {
        program[computer.ip + *tgt].fn = &cpy;
    } else {
        printf("well, looks like source fn is not a thing I know about, fuck!\n");
        printf("was attempting to toggle instruction at: %d (nr instructions: %d)\n", computer.ip + *tgt, nr_instructions);
        exit(1);
    }
    computer.ip++;
}

void out(INSTRUCTION* program, int whatevs, int *tgt) {
    if ( *tgt == computer.expected_out ) {
        computer.ip++;
        computer.expected_out = !computer.expected_out;
        computer.good_outs++;
    } else {
        computer.ip = nr_instructions + 1;
    }
}

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
            if ( *nr == 0 ) {
                offset++;
            }
            if ( *nr < 0 ) {
                offset++;
            }
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
            if ( *nr0 == 0 ) {
                offset++;
            }
            if ( *nr0 < 0 ) {
                offset++;
            }
            for ( int i = 1; *nr0 / i; i*=10 ) {
                offset++;
            }
		}
        //printf("%s\n", str);
       
        //printf("offset for parsing jump tgt: %d (%c)\n", offset, str[offset]);
        if ( str[offset] >= 'a' ) {
            inst.arg1 = &computer.reg[str[offset] - 'a'];
        } else {
            sscanf(str+offset,"%d", nr);
            inst.arg1 = nr;
        }
	} else if ( inst_st[0] == 'i' ) {
		inst.fn = &inc;
		inst.arg0 = nr;
		inst.arg1 = &computer.reg[str[4] - 'a'];
	} else if ( inst_st[0] == 'd' ) {
		inst.fn = &dec;
		inst.arg0 = nr;
		inst.arg1 = &computer.reg[str[4] - 'a'];
    } else if ( inst_st[0] == 't' ) {
        inst.fn = &tgl;
        inst.arg0 = nr;
        inst.arg1 = &computer.reg[str[4] - 'a'];
    } else if ( inst_st[0] == 'o' ) {
        inst.fn = &out;
        inst.arg0 = nr;
        inst.arg1 = &computer.reg[str[4] - 'a'];
	} else {
		printf("unknown instruction %s\n", inst_st);
	   	exit(1);
	}
	return inst;
} 

char fnp_to_char(void * fp){
    if ( fp == &cpy ) return 'c';
    if ( fp == &jnz ) return 'j';
    if ( fp == &inc ) return 'i';
    if ( fp == &dec ) return 'd';
    if ( fp == &tgl ) return 't';
    if ( fp == &out ) return 'o';
    return 'u';
}

int main() {
	FILE *fp = fopen("input-25","r");
	if ( fp == NULL ) {
		printf("cannot open file\n");
		exit(1);
	}
	char buf[30];
	INSTRUCTION program[1000];
	nr_instructions = 0;
	while (fgets(buf, 30, fp)) {
		program[nr_instructions++] = parse_line(buf);
	}
	fclose(fp);

    int iter;

    for ( iter = 1; computer.good_outs < GOOD_OUTS_TO_CHECK; iter++ ) {

        printf("trying now with %d\n", iter);
	computer.reg[0] = iter;
	computer.reg[1] = 0;
	computer.reg[2] = 0;
	computer.reg[3] = 0;
    computer.good_outs = 0;
    computer.expected_out = 0;
	computer.ip = 0;

	/*
	for ( int i = 0; i < nr_instructions; i++ ) {
		printf("arg0: %d, arg1: %d\n", *program[i].arg0, *program[i].arg1);
	}*/
   
    int t = 0; 

	while ( computer.ip < nr_instructions && computer.good_outs < GOOD_OUTS_TO_CHECK ) {
		//printf("ip: %d a: %d b: %d c: %d d: %d  %c %d %p (%d)\n", computer.ip, computer.reg[0], computer.reg[1], computer.reg[2], computer.reg[3], fnp_to_char(program[computer.ip].fn), *program[computer.ip].arg0, program[computer.ip].arg1, *program[computer.ip].arg1 );
		(*program[computer.ip].fn)(program, *program[computer.ip].arg0, program[computer.ip].arg1);
        /*t++;
        if ( t > 400 ) {
            break;
        }*/
	
    }

    }
	printf("my guess at a min good numer: %d\n", iter -1);
}
