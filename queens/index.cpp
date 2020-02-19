#include <iostream>
#include <stdio.h>

int combin(int m, int k ){
    unsigned long int comb = 1;
    if (m > 0 && k > 0 ) {
        for (int j = m ; j > m - k; j--){
            comb = comb * j;
        }
        for (int q = k; q > 0; q--){
            comb = comb / q;
        }
    }
    return comb;
}


void queenGen(unsigned int* config, int i, int m, int k){
    int q = 0;
    int r = i +1;
    int j = 0;
    for (int s = 1; s < k + 1; s++){
        int cs = j+1;
        int com = combin(m-cs,k-s);
        while ((r - com)>0){
            r -= com;
            cs += 1;
            com = combin(m-cs,k-s);
        }
        config[q++] = cs-1;
        printf("q is %d\n", q);
        j = cs;
    }
}

int main(void){
    
    int width = 4;
    int numQueens = 2;
    
    
    int m = width * width;
    int k = numQueens;
    
    unsigned int config[2] = {0};
    
    int i = 119;
    printf("The number of the total combinations is %u\n", combin(m, k ));
    
     queenGen (config, i, m, k);
     printf("id = %d quees=[%u, %u]\n", i,config[0], config[1]);
    
    return 0;
}



