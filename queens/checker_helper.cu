__device__
int countBits(unsigned int v) {
    int c; // c accumulates the total bits set in v
    for (c = 0; v; v >>= 1) {
        c += v & 1;
    }
    return c;
}

__device__
bool checkerFunc (unsigned int* queensList,int width, int numQueens){
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

__device__
int addtoSolution (unsigned int* queensList, int numQueens, unsigned int* solution, unsigned int* count, int pitch){
    // claim one of the valid solutions
    int solution_id = atomicAdd(count, 1);
    // printf("count = %d\n", solution_id);

    // // the below line sets solution = d_solution[solution_id]

    // solution is of the form [a,b] where a<b and each number
    // is an index of a queen into the 1-dimensional n*n-element chessboard
    
    for (int q = 0 ; q < numQueens; q++){
        solution[q] = queensList[q];
    }
    return solution_id;
    // return solution;
}