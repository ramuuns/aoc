#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "_timer.h"

typedef struct _ingredient {
    char *name;
    int seen_count;
    int num_allergens;
    int allergens[8];
} ingredient_t;

typedef struct _allergen {
    char *name;
    int num_ingredients;
    int ingredients[201];
} allergen_t;

int find_ingr_index(ingredient_t ingredients[201], char *name, int nr_ingredients) {
    int i = 0;
    for ( ; i < nr_ingredients; i++ ) {
        if ( strcmp(name, ingredients[i].name) == 0 ) {
            return i;
        }
    }
    return i;
}

int find_allergen_index(allergen_t allergens[8], char *name, int nr_allergens) {
    int i = 0;
    for ( ; i < nr_allergens; i++ ) {
        if ( strcmp(name, allergens[i].name) == 0 ) {
            return i;
        }
    }
    return i;
}

int comparator(const void* a, const void* b) {
    return strcmp(((allergen_t*)a)->name, ((allergen_t*)b)->name); 
}

int main() {
    timer_start();
    FILE *fp = fopen("input-21","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    char buff[600];
    int nr_ingredients = 0;
    ingredient_t ingredients[201];
    int nr_allergens = 0;
    allergen_t allergens[8];
    while ( fgets(buff, 600, fp) ) {
        int this_ingr[100];
        int this_ingr_cnt = 0;
        int offset = 0;
        int reading_ingredients = 1;
        for ( int i = 0; buff[i]; i++ ) {
            if ( reading_ingredients ) {
                if ( buff[i] == ' ' ) {
                    char *iname = calloc((i - offset + 1), sizeof(char));
                    strncpy(iname, buff+offset, i - offset);
                    int ing_idx = find_ingr_index(ingredients, iname, nr_ingredients);
                    if ( ing_idx == nr_ingredients ) {
                        ingredients[ing_idx].name = iname;
                        ingredients[ing_idx].seen_count = 1;
                        ingredients[ing_idx].num_allergens = 0;
                        nr_ingredients++;
                    } else {
                        ingredients[ing_idx].seen_count++;
                    }
                    this_ingr[this_ingr_cnt++] = ing_idx;
                    offset = i+1;
                } else if ( buff[i] == '(' ) {
                    reading_ingredients = 0;
                    i += 9; //skip contains
                    offset = i+1;
                }
            } else {
                if ( buff[i] == ',' || buff[i] == ')' ) {
                    char *aname = calloc((i - offset + 1), sizeof(char));
                    strncpy(aname, buff+offset, i - offset);
                    int all_idx = find_allergen_index(allergens, aname, nr_allergens);
                    if (all_idx == nr_allergens) {
                        allergens[all_idx].name = aname;
                        allergens[all_idx].num_ingredients = this_ingr_cnt;
                        for ( int k = 0; k < this_ingr_cnt; k++ ) {
                            allergens[all_idx].ingredients[k] = this_ingr[k];
                            ingredients[this_ingr[k]].allergens[ingredients[this_ingr[k]].num_allergens++] = all_idx;
                        }
                        nr_allergens++;
                    } else {
                        for ( int j = 0; j < allergens[all_idx].num_ingredients; j++ ) {
                            int found = 0;
                            for ( int k = 0; k < this_ingr_cnt; k++ ) {
                                if ( allergens[all_idx].ingredients[j] == this_ingr[k] ) {
                                    found = 1;
                                    break;
                                }
                            }
                            if ( ! found ) {
                                int ingr = allergens[all_idx].ingredients[j];
                                for ( int k = 0; k < ingredients[ingr].num_allergens; k++ ) {
                                    if ( ingredients[ingr].allergens[k] == all_idx ) {
                                        ingredients[ingr].allergens[k] = ingredients[ingr].allergens[ ingredients[ingr].num_allergens - 1 ];
                                        ingredients[ingr].num_allergens--;
                                        break;
                                    }
                                }
                                allergens[all_idx].ingredients[j] = allergens[all_idx].ingredients[ allergens[all_idx].num_ingredients - 1 ];
                                allergens[all_idx].num_ingredients--;
                                j--;
                            }
                        }
                    }
                    offset = i+2;
                }
            }
        }
    }

    fclose(fp);

    int count = 0;
    for ( int i = 0; i < nr_ingredients; i++ ) {
        if ( ingredients[i].num_allergens == 0 ) {
            count += ingredients[i].seen_count;
        }
    }

    printf("nr of times non-alergen ingredients are seen: %d\n", count);

    for ( int i = 0; i < nr_allergens; i++ ) {
        if ( allergens[i].num_ingredients == 1 ) {
            int kicked = 0;
            for ( int k = 0; k < nr_allergens; k ++ ) {
                if ( i == k ) continue;
                for ( int j = 0; j < allergens[k].num_ingredients; j++ ) {
                    if ( allergens[k].ingredients[j] == allergens[i].ingredients[0] ) {
                        allergens[k].ingredients[j] = allergens[k].ingredients[  allergens[k].num_ingredients - 1 ];
                        allergens[k].num_ingredients--;
                        kicked = 1;
                        break;
                    }
                }
            }
            if ( kicked ) {
                i = -1;
            }
        }
    }
    qsort(allergens, nr_allergens, sizeof(allergen_t), &comparator);
    for ( int i =0; i < nr_allergens; i++ ) {
        if ( i != 0 ) { printf(","); }
        printf("%s", ingredients[ allergens[i].ingredients[0] ].name);
    }
    printf("\n");

    for ( int i = 0; i < nr_allergens; i++ ) {
        free(allergens[i].name);
    }
    for ( int i = 0; i < nr_ingredients; i++ ) {
        free(ingredients[i].name);
    }
    printtime();
}
