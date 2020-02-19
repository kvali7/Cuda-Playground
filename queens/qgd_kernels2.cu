
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */

//  #include <math.h>

//  #define BOARDSIZE 6
//  #define NUMQUEENS 3
 
 #define BOARDSIZE 6
 #define NUMQUEENS 3

 #include "checker_helper.cu"
#include "comb_creator.cu"
 
  __global__
  void qgdKernel(int n, int a, bool one, bool all, int pitch,
                 unsigned int * d_solutions, unsigned int * count, unsigned long int comb) {
      // this kernel is completely hardcoded to the 4x4 board
      // I'm not pretending otherwise
  
      int tid = threadIdx.x + blockIdx.x * blockDim.x;

    if ( all == true  ){
        // we know that for n=4, a=2, so knock out all boards where a != 2
        // int bitcount = countBits(tid);
        // if (bitcount != a) { return; }
    
        if (tid >= comb) return;

        int numQueens = NUMQUEENS;
        int width = BOARDSIZE;

        // create queens List for n = 4 the size of the proposed solution is 2
        unsigned int queensList[NUMQUEENS] = {0};
        // int temp = tid;
        // for (unsigned int c = 0, qi = 0 ; temp ; temp >>= 1, c++){
        //     if (temp & 1){
        //         queensList[qi] = c;
        //         qi++;
        //     }
        // }
        
        queenGen (queensList, tid, width * width, numQueens);
        if (checkerFunc (queensList, width, numQueens)) 
            addSolution (queensList,  numQueens, d_solutions, count, pitch);
    }
  }


  // Store your solutions in d_solution, which has already been allocated for you
  void qgd(int n, int a, bool one, bool all, int pitch,
           unsigned long long numSolutions, unsigned int * d_solutions,
           unsigned int * count) {
    
      // there are 2^16 possible configurations of queens on a 4x4 chessboard
      // 2^8 blocks of 2^8 threads each will check them all (brute force)
      int width = n;
      int numQueens = a;

      //all combinations
      printf("fact ");
      unsigned long int comb = 1;
      int m = width*width;
      int k = numQueens;
      for (int j = m ; j > m - k; j--){
            comb = comb * j;
      }
      for (int q = k; q > 0; q--){
          comb = comb / q;
      }
      printf("The number of the total combinations is %u\n", comb);
      //generate every possible combinations on the memory
    

      qgdKernel<<< 1<<8, 1<<8 >>>(width, numQueens, one, all, pitch, d_solutions, count, comb);
    //   qgdKernel<<< 1<<10, 1<<6 >>>(n, a, one, all, pitch, d_solutions, count)
    int even = !(width % 2);
    printf("Is it even? %d\n", even);
    // printf("number of found solutions = %u\n", *count);

    // unsigned int* solution = (unsigned int*) ((char*) d_solutions + solution_id * pitch);


    // unsigned int* solution = (unsigned int*) (char*) d_solution ;
    // // solution is of the form [a,b] where a<b and each number
    // // is an index of a queen into the 1-dimensional n*n-element chessboard
    // for (int q = 0 ; q < numQueens; q++){
    //     solution[q] = queensList[q];
    // }
  }
  