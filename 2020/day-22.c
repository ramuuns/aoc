#include <stdio.h>
#include "_timer.h"

#define NR_CARDS 60

int calc_score(int p1[NR_CARDS], int p1_top, int p1_end) {
    int score = 0;
    for ( int i = 1; i <= ((p1_end + NR_CARDS) - p1_top) % NR_CARDS; i++ ) {
        score += i * p1[(NR_CARDS + p1_end - i) % NR_CARDS];
    }
    return score;
}

int play_game(int p1[NR_CARDS], int p2[NR_CARDS], int p1_end, int p2_end, int *score, int recursive) {
    int p1_top = 0;
    int p2_top = 0;
    int seen_scores[NR_CARDS][NR_CARDS][30][2];
    int rounds = 0;

    int p1maxval = 0;
    int p2maxval = 0;

    if ( recursive > 1 ) {
        // check if we can return early
        for ( int i = 0; i < p1_end; i++ ) {
            p1maxval = p1maxval > p1[i] ? p1maxval : p1[i];
        }
        for ( int i = 0; i < p2_end; i++ ) {
            p2maxval = p2maxval > p2[i] ? p2maxval : p2[i];
        }
        if ( p1maxval > p2maxval ) {
            return 1;
        }
        for ( int i = 0; i <= p2maxval; i++ ) {
            for (int k = 0; k <= p2maxval; k++ ) {
                seen_scores[i][k][0][0] = 0;
            }
        }
    }

    while ( 1 ) {

        /*
        printf("-- Round %d (Game %d) --\n", rounds+1, recursive);
        printf("Player 1's deck: ");
        for ( int i = p1_top; i != p1_end; i = (i+1) % NR_CARDS ) {
            if ( i != p1_top ) printf(", ");
            printf("%d", p1[i]);
        }
        printf("\n");
        printf("Player 2's deck: ");
        for ( int i = p2_top; i != p2_end; i = (i+1) % NR_CARDS ) {
            if ( i != p2_top ) printf(", ");
            printf("%d", p2[i]);
        }
        printf("\n");
        printf("Player 1 plays: %d\n", p1[p1_top]);
        printf("Player 2 plays: %d\n", p2[p2_top]);
*/

        int p1_win = 0;
        int p2_win = 0;
        if ( recursive ) {

            int p1_score = calc_score(p1, p1_top, p1_end);

            int p2_score = calc_score(p2, p2_top, p2_end);
            int num_times_this_top = seen_scores[p1[p1_top]][p2[p2_top]][0][0];
            int k = 0;
            for ( k = 0; k < num_times_this_top; k++ ) {
                if ( seen_scores[p1[p1_top]][p2[p2_top]][1+k][0] == p1_score && seen_scores[p1[p1_top]][p2[p2_top]][1+k][1] == p2_score ) {
                    return 1;
                }
            }
            if ( k > 28 ) {
                printf("guess we need a bigger hash\n");
                return -1;
            }
            seen_scores[p1[p1_top]][p2[p2_top]][1+k][0] = p1_score;
            seen_scores[p1[p1_top]][p2[p2_top]][1+k][1] = p2_score;
            seen_scores[p1[p1_top]][p2[p2_top]][0][0]++;

            rounds++;

            if ( p1[p1_top] < ((p1_end + NR_CARDS) - p1_top) % NR_CARDS &&
                 p2[p2_top] < ((p2_end + NR_CARDS) - p2_top) % NR_CARDS ) {
                int newp1[NR_CARDS];
                int newp2[NR_CARDS];
                int newp1_end = 0;
                int newp2_end = 0;
                for ( int i = 0; i < p1[p1_top]; i++ ) {
                    newp1[newp1_end++] = p1[(i + p1_top + 1) % NR_CARDS];
                }
                for ( int i = 0; i < p2[p2_top]; i++ ) {
                    newp2[newp2_end++] = p2[(i + p2_top + 1) % NR_CARDS];
                }
//                printf("\nGoing deeper\n");
                p1_win = play_game(newp1, newp2, newp1_end, newp2_end, score, recursive + 1);
                if ( p1_win == -1 ) {
                    return -1;
                }
                p2_win = !p1_win;
            }

        }

        if ( p1_win || (!p2_win && p1[p1_top] > p2[p2_top] ) ) {
//            printf("Player 1 wins the round ( %d %d)!\n\n", rounds, recursive);
            p1[p1_end] = p1[p1_top];
            p1_end = (p1_end + 1) % NR_CARDS;
            p1[p1_end] = p2[p2_top];
            p1_end = (p1_end + 1) % NR_CARDS;
            p1_top = (p1_top + 1) % NR_CARDS;
            p2_top = (p2_top + 1) % NR_CARDS;
        } else {
//            printf("Player 2 wins the round ( %d %d)!\n\n", rounds, recursive);
            p2[p2_end] = p2[p2_top];
            p2_end = (p2_end + 1) % NR_CARDS;
            p2[p2_end] = p1[p1_top];
            p2_end = (p2_end + 1) % NR_CARDS;
            p2_top = (p2_top + 1) % NR_CARDS;
            p1_top = (p1_top + 1) % NR_CARDS;
        }
        if ( p1_top == p1_end || p2_top == p2_end ) {
            break;
        }
    }
    if ( p1_top != p1_end ) {
        if ( recursive < 2 ) {
            *score = calc_score(p1, p1_top, p1_end);
        }
//        printf("[END]-- Round %d (Game %d) --\n", rounds+1, recursive);
        return 1;
    } else {
        if ( recursive < 2 ) {
            *score = calc_score(p2, p2_top, p2_end);
        }
//        printf("[END]-- Round %d (Game %d) --\n", rounds+1, recursive);
        return 0;
    }
}

int main() {
    timer_start();
    FILE *fp = fopen("input-22","r");
    char buff[30];
    int p1[NR_CARDS];
    int p2[NR_CARDS];
    int part2_p1[NR_CARDS];
    int part2_p2[NR_CARDS];
    int reading_player1 = 1;
    int p1_end = 0;
    int p2_end = 0;
    while ( fgets(buff, 30, fp ) ) {
        if ( buff[0] == '\n' ) {
            reading_player1 = 0;
        }
        if ( buff[0] >= '0' && buff[0] <= '9' ) {
            if ( reading_player1 ) {
                sscanf(buff, "%d", &p1[p1_end]);
                sscanf(buff, "%d", &part2_p1[p1_end++]);
            } else {
                sscanf(buff, "%d", &p2[p2_end]);
                sscanf(buff, "%d", &part2_p2[p2_end++]);
            }
        }
    }

    int score;
    play_game(p1, p2, p1_end, p2_end, &score, 0);
    printf("score part1: %d\n", score);
    play_game(part2_p1, part2_p2, p1_end, p2_end, &score, 1);
    printf("score part2: %d\n", score);


    printtime();
}
