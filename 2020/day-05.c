#include <stdio.h>

int main() {
    FILE *fp = fopen("input-05","r");
    if ( !fp ) {
        printf("no file\n");
        return 1;
    }
    int max = 0;
    int curr = 0;
    char buff[255];
    int min = 1024;
    int my_seat = ((1 << 10 ) + 1) << 9; // sum of 1 ... 1024 
    /* to explain the above a bit
     * 1024 is 2^10 (so the 1 << 10 ) would give you that,
     * then you'd multiply it by 1024 again and add another 1024 (because to get the sum of 1..n you do a n*n+1/2)
     * but we can cheat here - (1 << 10) << 10 is 1024 squared but (1 << 10 + 1) << 10 is 1024 * 1024 + 1024 
     * but since we're gonna be dividing that by two anyway, we only shift it by << 9 in the first place
     */

    while ( fgets(buff, 255, fp ) ) {
        curr = 0;
        /* notice that in ascii both B and R have 0 as their third byte
         * and both F and L have 1 there, so that's how you can tell them appart without
         * having to treat them differently */ 
        for ( int i = 0; i < 10; i++ ) {
            curr = curr << 1;
            curr += !(buff[i] & 4); // B and R & 4 are zero, but we need them as 1 so the !
        }
        if ( curr > max ) {
            max = curr;
        }
        if ( curr < min ) {
            min = curr;
        }
        my_seat -= curr;
    }

    /* Since all the seats between min and max are occupied and we have a sum of all
     * integers from 1 to 1024, our seat will be the integer that is missing from this
     * sum. So we remove the sum of 1..min and the sum from max to 1024 from our total sum
     * this will give us our seat number
     */

    my_seat -= min*(min-1) >> 1; // here we remove from our sum the numbers between 1 and min
    my_seat -= ((((1 << 10) + 1) << 10) - max*(max+1)) >> 1; // and here the ones between max and 1024
    fclose(fp);
    printf("max: %d\n", max);
    printf("seatid by math :%d\n", my_seat);
}
