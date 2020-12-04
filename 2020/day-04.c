#include <stdio.h>
#include <string.h>

#define BYR 0x1
#define IYR 0x2
#define EYR 0x4
#define HGT 0x8
#define HCL 0x10
#define ECL 0x20
#define PID 0x40
#define CID 0x80

#define MASK ( BYR | IYR | EYR | HGT | HCL | ECL | PID )

int is_valid(int flags) {
    return (flags & MASK) == MASK ? 1 : 0;
}

int key_to_flag(char key[4]) {
    switch (key[0]) {
        case 'b':
            return BYR;
        case 'i':
            return IYR;
        case 'e':
            if ( key[1] == 'y' ) return EYR;
            return ECL;
        case 'h':
            if ( key[1] == 'g' ) return HGT;
            return HCL;
        case 'p':
            return PID;
        case 'c':
            return CID;
        default:
            return 0;
    } 
}

int is_valid_value(int type, char value[255]) {
    if ( type == CID ) {
        return 1;
    }
    int intval = 0;
    char sval[255];
    if ( type == BYR ) {
        if ( strlen(value) != 4 ) {
            return 0;
        }
        sscanf(value, "%d", &intval);
        if ( intval < 1920 || intval > 2002 ) {
            return 0;
        }
        return 1;
    }
    if ( type == IYR ) {
        if ( strlen(value) != 4 ) {
            return 0;
        }
        sscanf(value, "%d", &intval);
        if ( intval < 2010 || intval > 2020 ) {
            return 0;
        }
        return 1;
    }
    if ( type == EYR ) {
        if ( strlen(value) != 4 ) {
            return 0;
        }
        sscanf(value, "%d", &intval);
        if ( intval < 2020 || intval > 2030 ) {
            return 0;
        }
        return 1;
    }
    if ( type == HGT ) {
        if ( sscanf(value, "%d%s", &intval, sval) == 2 ) {
            if ( strlen(sval) != 2 ) {
                return 0;
            }
            if ( sval[0] == 'c' && sval[1] == 'm' ) {
                if ( intval < 150 || intval > 193 ) {
                    return 0;
                } else {
                    return 1;
                }
            }
            if ( sval[0] == 'i' && sval[1] == 'n' ) {
                if ( intval < 59 || intval > 76 ) {
                    return 0;
                } else {
                    return 1;
                }
            }
        }
        return 0;
    }
    if ( type == HCL ) {
        if ( value[0] != '#' ) {
            return 0;
        }
        if ( strlen(value) != 7 ) {
            return 0;
        }
        intval = 1; //is_valid
        for ( int i = 1; i < 7; i++ ) {
            if ( (value[i] < '0' || value[i] > '9') && ( value[i] < 'a' || value[i] > 'f' ) ) {
                intval = 0;
                break;
            }
        }
        return intval;
    }
    if ( type == ECL ) {
        // amb blu brn gry grn hzl oth
        if ( strlen(value) != 3 ) {
            return 0;
        }
        if ( 
           (value[0] == 'a' && value[1] == 'm' && value[2] == 'b') ||
           (value[0] == 'b' && value[1] == 'l' && value[2] == 'u') ||
           (value[0] == 'b' && value[1] == 'r' && value[2] == 'n') ||
           (value[0] == 'g' && value[1] == 'r' && value[2] == 'y') ||
           (value[0] == 'g' && value[1] == 'r' && value[2] == 'n') ||
           (value[0] == 'h' && value[1] == 'z' && value[2] == 'l') ||
           (value[0] == 'o' && value[1] == 't' && value[2] == 'h') ) {
            return 1;
        }
        return 0;
    }
    if ( type == PID ) {
        if ( strlen(value) != 9 ) {
            return 0;
        }
        intval = 1;
        for ( int i = 1; i < 9; i++ ) {
            if ( (value[i] < '0' || value[i] > '9') ) {
                intval = 0;
                break;
            }
        }
        return intval;
    }
    return 0;
}

int main() {
    FILE *fp = fopen("input-04","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int flags = 0;
    int num_valid = 0;
    int num_valid_part2 = 0;
    int all_fields_are_valid = 1;
    int key_flag = 0;
    char key[4];
    char value[255];
    int offset = 0;
    char buff[255];
    while ( fgets(buff, 255, fp) ) {
        if ( buff[0] != '\n' ) {
            offset = 0;
            while ( sscanf(buff+offset, "%3s:%s ", key, value) == 2 ) {
                offset += 5 + strlen(value);
                key_flag = key_to_flag(key);
                flags = flags | key_flag;
                all_fields_are_valid = all_fields_are_valid && is_valid_value(key_flag, value);
            }
        } else {
            if ( is_valid(flags) ) {
                num_valid++;
                if ( all_fields_are_valid ) {
                    num_valid_part2++;
                }
            }
            flags = 0;
            all_fields_are_valid = 1;
        }
    }
    fclose(fp);
    if ( flags && is_valid(flags) ) {
        num_valid++;
        if ( all_fields_are_valid ) {
            num_valid_part2++;
        }
    }
    printf("num valid %d\n", num_valid);
    printf("num valid part 2 %d\n", num_valid_part2);
}
