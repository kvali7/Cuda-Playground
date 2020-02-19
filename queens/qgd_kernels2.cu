
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */


 #include "checker_helper.cu"
#include "comb_creator.cu"
 
__global__
void qgdKernelOne(int n, int a, int pitch,
    unsigned int* d_solution, unsigned int* count, unsigned long int comb, unsigned int* flag) {

    unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
    // int stride = blockDim.x * gridDim.x;
    // for (unsigned long long int id = tid; id < 10 * tid; id += stride)

        // if (tid >= comb || *flag) return;
        if (*flag) return;
        int width = n;

        int numQueens = a;

        // create queens List of max size 16
        unsigned int queensList[16] = {0};
        queenGen (queensList, tid, width * width, numQueens);
        if (!checkerFunc (queensList, width, numQueens) ) return;
          addtoSolution (queensList,  numQueens, d_solution, count, pitch);
          int valflag = atomicAdd(flag, 1);
          // printf("flag = %d\n",valflag);
  
}

  __global__
  void qgdKernel(int n, int a, int pitch,
        unsigned int* d_solution, unsigned int* count, unsigned long int comb) {

  
      unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
      // int stride = blockDim.x * gridDim.x;
      // for (unsigned long long int id = tid; id < 10 * tid; id += stride){
        
          // if (tid >= comb) return;
          int width = n;

          int numQueens = a;

          // create queens List of max size 16
          unsigned int queensList[16] = {0};
          queenGen (queensList, tid, width * width, numQueens);
          if (!checkerFunc (queensList, width, numQueens)) return;
            addtoSolution (queensList,  numQueens, d_solution, count, pitch);

      // }
      
  }


  // Store your solutions in d_solution, which has already been allocated for you
  void qgd(int n, int a, bool one, bool all, int pitch,
           unsigned long long numSolutions, unsigned int * d_solution,
           unsigned int * count) {
    
      // there are 2^16 possible configurations of queens on a 4x4 chessboard
      // 2^8 blocks of 2^8 threads each will check them all (brute force)
      int width = n;
      int numQueens = a;
     
      unsigned int *flag;
      cudaMallocManaged(&flag, sizeof(unsigned int));
      *flag = 0;

      //all combinations
      // printf("fact ");
      unsigned long long int comb = 1;
      int m = width*width;
      int k = numQueens;
      for (int j = m ; j > m - k; j--){
            comb = comb * j;
      }
      for (int q = k; q > 0; q--){
          comb = comb / q;
      }


      unsigned long int blockSize;

      if (width < 5)
        blockSize = 1 << 5;
      else
        blockSize = 1<<10;
            //dynamic block size for all
      unsigned long long int numBlocks;

      unsigned long long int numBlocksAllTable[] = {
        1<<2, 1<<2, 1<<2, 1<<2, 1<<2, 1<<2, 1<<6, 1<<8, 1<<13, 1<<15, 1<<16,  1<<17, 1<<24, 1<<27};

      unsigned long long int numBlocksOneTable[] = {
        1<<1, 1<<1, 1<<1, 1<<1, 1<<1, 1<<1, 1<<1, 1<<4, 1<<5, 1<<10, 1<<14, 1<<17,  1<<19, 1<<24, 1<<27};
      if (all == true && one == false)
        numBlocks = comb / blockSize + 1;
      else if (one == true && all ==false)
        numBlocks = numBlocksOneTable[width];
      else
        printf("all one error!\n");

      // if (numBlocks < 1)
      //   numBlocks = 1;
      // if (all == true){

      //      n = 2   0.32
      //  n = 3   0.32
      //  n = 4   0.37
      //  n = 5   0.5 ms
      //   n = 6   0.6 ms
      //     n = 7   4 ms
      // n = 8   232 ms
      // n = 9   756 ms
      //n = 10   1 secs
      //n = 11    1.2 secs
      // n = 12   85 secs 
      // n = 13  273 secs

      // if (one == true){
      // n = 2   0.32
      //  n = 3   0.32
      //   n = 4   0.33
      //  n = 5   0.4 ms
      // n = 6   0.6 ms
      //  n = 7   0.9 ms
      //   n = 8   1 ms
      //   n = 9   11 ms
      //  n = 10   365 ms
      //   n = 11    856 ms
      //     n = 12   1.9 secs 
      //   n = 13     50 secs
      //  n = 14     325 secs
    
  
        // numBlocks = 224;

      //  blockSize = 1<<10;
      //  numBlocks = 1<<2;
  
      // printf("The number of the total combinations is %llu\n", comb);
      //  unsigned long long int threads;

      // threads = numBlocks * blockSize;

      // printf("thread = %d, blocks = %d The number of the total threads is %llu\n", blockSize, numBlocks, threads);

      // printf("Total threads %llu\n", threads);
    

      if (all == true && one == false )
        qgdKernel<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solution, count, comb);
      else if (all == false && one == true)
        qgdKernelOne<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solution, count, comb, flag);

  }
  