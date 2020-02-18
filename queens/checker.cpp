#include <stdio.h>
#include <iostream>



#define BOARDSIZE 5
#define NUMQUEENS 3

int countBits(unsigned int v, int boardSize) {
    int c ;
    int i;
    for (c = 0, i = 0; v; v >>= 1, i++) {
        c += v & 1;
    }
    return c;
}


int printChess (unsigned int in_checkArr[]){


    int boardSize = BOARDSIZE;
    int numQueens = NUMQUEENS ;

    //print all
    for (int lk = 0; lk < boardSize; lk ++){
        int temp = in_checkArr[lk];
        printf("%u\n", temp);
        for (int lj = boardSize-1; lj >=  0; lj --){
            if (temp & 1 << lj)
                printf("1  " );
            else
                printf("0  ");
        }
        printf("\n");

    }
    printf("\n\n");


}

int main(void){
    int boardSize = BOARDSIZE;
    int numQueens = NUMQUEENS;
    int queensList[NUMQUEENS] = {2,17,22};
    bool ifCheck = true;
    //max we can do is 32 x 32
    unsigned int in_checkArr[32] ={0};

    for (int queen = 0; queen < numQueens; queen++){
        int posqueen = queensList[queen];
        int row = posqueen / boardSize;
        int col = posqueen % boardSize;
        //queen pos
        in_checkArr[row] |= 1 << col;
        //row easy!
        in_checkArr[row] |=  0xffffffff;
        for (int r = 0; r < boardSize; r++){
            // column in loop
            in_checkArr[r] |=  1 << col;
            // main diagon
            if (row + col - r < boardSize && row + col -r >= 0) 
                in_checkArr[r] |=  1 << row + col - r;
            // other diagon
            if (col - row + r >= 0 && col - row + r < boardSize) 
                in_checkArr[r] |=1 << col - row + r;
            if (countBits(in_checkArr[r], boardSize) < boardSize && queen == numQueens - 1)
                ifCheck = false;
        }
    }

    printf("result = %d\n", ifCheck);
    return 0;
}


//  //diagon in loop and switch
//             switch (posqueen % boardSize){
//                 case 0:
//                     printf("hey there \n");
//                 case 1:
//                     printf("hey there \n");
//                 case 2:
//                     printf("hey there \n");
//                 case 3:
//                     printf("hey there \n");
//                 case 4:
//                     printf("hey there \n");
//                 case 5:
//                     printf("hey there \n");
//                 case 6:
//                     printf("hey there \n");
//                 case 7:
//                     printf("hey there \n");
//                 case 8:
//                     printf("hey there \n");
//                 case 9:
//                     printf("hey there \n");
//                 case 10:
//                     printf("hey there \n");
//                 case 11:
//                     printf("hey there \n");
//                 case 12:
//                     printf("hey there \n");
//                 case 13:
//                     printf("hey there \n");
//                 case 14:
//                     printf("hey there \n");
//                 case 15:
//                     printf("hey there \n");
//                 case 16:
//                     printf("hey there \n");
//                 case 17:
//                     printf("hey there \n");
//                 case 18:
//                     printf("hey there \n");
//                 case 19:
//                     printf("hey there \n");
//                 case 20:
//                     printf("hey there \n");                     
//                 case 21:
//                     printf("hey there \n");
//                 case 22:
//                     printf("hey there \n");     
//                 case 23:
//                     printf("hey there \n");
//                 case 24:
//                     printf("hey there \n");
//                 case 25:
//                     printf("hey there \n");
//                 case 26:
//                     printf("hey there \n");
//                 case 27:
//                     printf("hey there \n");
//                 case 28:
//                     printf("hey there \n");
//                 case 29:
//                     printf("hey there \n");
//                 case 30:
//                     printf("hey there \n");
//                 case 31:
//                     printf("gey\n");           
//             }










