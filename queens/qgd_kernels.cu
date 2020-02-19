
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */

 #include "checker_helper.cu"
 #include <math.h>

//  #define BOARDSIZE 6
//  #define NUMQUEENS 3
 
//  #define BOARDSIZE 4
//  #define NUMQUEENS 2
 
  __global__
  void qgdKernel(int n, int a, bool one, bool all, int pitch,
                 unsigned int * d_solutions, unsigned int * count) {
      // this kernel is completely hardcoded to the 4x4 board
      // I'm not pretending otherwise
  
      int tid = threadIdx.x + blockIdx.x * blockDim.x;

    if ( all == true  ){
        // we know that for n=4, a=2, so knock out all boards where a != 2
        int bitcount = countBits(tid);
        if (bitcount != a) { return; }
    
        int width = n;

        int numQueens = a;
        // create queens List for n = 4 the size of the proposed solution is 2
        unsigned int queensList[16] = {0};
        int temp = tid;
        for (unsigned int c = 0, qi = 0 ; temp ; temp >>= 1, c++){
            if (temp & 1){
                queensList[qi] = c;
                qi++;
            }
        }
        // unsigned int list[NUMQUEENS] = {   0	,   2	 ,  3	,  16	 , 51};

        // for (int q=0; q< numQueens; q++)
        //     queensList[q] = list[q];

        // if (checkerFunc (queensList, width, numQueens)) 
        //     // addSolution (queensList,  numQueens, d_solutions, count, pitch);
        //     printf("Solution\n");
        // else
        //     printf("This is not a Solution\n");

        if (checkerFunc (queensList, width, numQueens)) {
            addSolution (queensList,  numQueens, d_solutions, count, pitch);
            
        }
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
      qgdKernel<<< 1<<8, 1<<8 >>>(width, numQueens, one, all, pitch, d_solutions, count);
    //   qgdKernel<<< 1<<10, 1<<6 >>>(n, a, one, all, pitch, d_solutions, count);
    
  }
  