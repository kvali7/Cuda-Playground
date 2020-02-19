
#include <fstream>
#include <string>


#include <stdio.h>
#include <iostream>
#define BOARDSIZE 8
#define NUMQUEENS 5

int countBits(unsigned int v) {
    int c; // c accumulates the total bits set in v
    for (c = 0; v; v >>= 1) {
        c += v & 1;
    }
    return c;
}

bool checkerFunc (int* queensList,int width, int numQueens){
    ////input exceptions
    // if (numQueens > width){
    //     printf("The Number of Queens is greater than width of the board\n");
    // }
    bool ifCheck = true;
    ////max we can do is 32 x 32
    unsigned int in_checkArr[32] ={0};
    for (int q = 0; q < numQueens; q++){
        int posqueen = queensList[q];
        // if (posqueen < 0 || posqueen >= width * width){
        //     printf("The position  of Queen is invalid\n");
        // }
        int row = posqueen/width;
        int col = posqueen % width;
        ////row easy!
        in_checkArr[row] |=  0xffffffff;
        for (int r = 0; r < width; r++){
            ////column in loop
            in_checkArr[r] |=  1 << col;
            ////main diagon
            if (row + col - r < width && row + col -r >= 0) 
                in_checkArr[r] |=  1 << row + col - r;
            ////other diagon
            if (col - row + r >= 0 && col - row + r < width) 
                in_checkArr[r] |=1 << col - row + r;
            if (countBits(in_checkArr[r]) < width && q == numQueens - 1)
                ifCheck = false;
        }
    }

    return ifCheck; 
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
    int width = BOARDSIZE;
    int numQueens = NUMQUEENS;
    int config[NUMQUEENS] = {0};
    // int list[NUMQUEENS] = {   0	,   2	 ,  3	,  16	 , 51};
    int list[NUMQUEENS] = {   4	,   27	 ,  33	,  56	 , 55};
    bool ifCheck;
    

    // read a line from file  in while loop
        // read elements form the line to config array 5 elements
        for (int q=0; q< numQueens; q++)
            config[q] = list[q];

        ifCheck = checkerFunc (config, width, numQueens);
        printf("result = %d\n", ifCheck);
    //
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










