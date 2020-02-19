
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */

//  #include <math.h>

//  #define BOARDSIZE 4
//  #define NUMQUEENS 2
 
//  #define BOARDSIZE 12
//  #define NUMQUEENS 6

 #include "checker_helper.cu"
#include "comb_creator.cu"
 
__global__
void qgdKernelOne(int n, int a, int pitch,
               unsigned int * d_solutions, unsigned int * count, unsigned long int comb) {
    // this kernel is completely hardcoded to the 4x4 board
    // I'm not pretending otherwise

    unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;

  
    // we know that for n=4, a=2, so knock out all boards where a != 2
    // int bitcount = countBits(tid);
    // if (bitcount != a) { return; }

    if (tid >= comb) return;
    int width = n;

    int numQueens = a;

    // create queens List for n = 4 the size of the proposed solution is 2
    unsigned int queensList[16] = {0};

    
    queenGen (queensList, tid, width * width, numQueens);
    if (checkerFunc (queensList, width, numQueens)) 
        addSolution (queensList,  numQueens, d_solutions, count, pitch);
  
}

  __global__
  void qgdKernel(int n, int a, int pitch,
                 unsigned int * d_solutions, unsigned int * count, unsigned long int comb) {
      // this kernel is completely hardcoded to the 4x4 board
      // I'm not pretending otherwise
  
      unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;

    
      // we know that for n=4, a=2, so knock out all boards where a != 2
      // int bitcount = countBits(tid);
      // if (bitcount != a) { return; }
  
      if (tid >= comb) return;
      int width = n;

      int numQueens = a;

      // create queens List for n = 4 the size of the proposed solution is 2
      unsigned int queensList[16] = {0};

      
      queenGen (queensList, tid, width * width, numQueens);
      if (checkerFunc (queensList, width, numQueens)) 
          addSolution (queensList,  numQueens, d_solutions, count, pitch);
    
  }


  // Store your solutions in d_solution, which has already been allocated for you
  void qgd(int n, int a, bool one, bool all, int pitch,
           unsigned long long numSolutions, unsigned int * d_solutions,
           unsigned int * count) {
    
      // there are 2^16 possible configurations of queens on a 4x4 chessboard
      // 2^8 blocks of 2^8 threads each will check them all (brute force)
      int width = n;
      int numQueens = a;
      // TODO:
      int blockSize = 1<<10;
      //dynamic block size
      int numBlocks = 1<<6;


      //all combinations
      printf("fact ");
      unsigned long long int comb = 1;
      unsigned long long int threads;
      int m = width*width;
      int k = numQueens;
      for (int j = m ; j > m - k; j--){
            comb = comb * j;
      }
      for (int q = k; q > 0; q--){
          comb = comb / q;
      }
  
      printf("The number of the total combinations is %u\n", comb);

      threads = numBlocks * blockSize;

      printf("The number of the total threads is %u\n", threads);

      // printf("Total threads %llu\n", threads);
      //generate every possible combinations on the memory
    

      if (all == true && one == false )
        qgdKernel<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solutions, count, comb);
      else if (all == false && one == true)
        qgdKernelOne<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solutions, count, comb);

  }
  