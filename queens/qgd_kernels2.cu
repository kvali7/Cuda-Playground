
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */


 #include "checker_helper.cu"
#include "comb_creator.cu"
 
__global__
void qgdKernelOne(int n, int a, int pitch,
    unsigned int * d_solution, unsigned int * count, unsigned long int comb, unsigned int* flag) {

    unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
    // int stride = blockDim.x * gridDim.x;
    // for (unsigned long long int id = tid; id < 10 * tid; id += stride){
  
        // we know that for n=4, a=2, so knock out all boards where a != 2
        // int bitcount = countBits(tid);
        // if (bitcount != a) { return; }
        if (tid >= comb || *flag) return;
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
        unsigned int * d_solution, unsigned int * count, unsigned long int comb) {

  
      unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
      // int stride = blockDim.x * gridDim.x;
      // for (unsigned long long int id = tid; id < 10 * tid; id += stride){
    
          // we know that for n=4, a=2, so knock out all boards where a != 2
          // int bitcount = countBits(tid);
          // if (bitcount != a) { return; }
      
          if (tid >= comb) return;
          int width = n;

          int numQueens = a;

          // create queens List of max size 16
          unsigned int queensList[16] = {0};
          queenGen (queensList, tid, width * width, numQueens);
          if (!checkerFunc (queensList, width, numQueens)) return;
            addtoSolution (queensList,  numQueens, d_solution, count, pitch);
      
  }


  // Store your solutions in d_solution, which has already been allocated for you
  void qgd(int n, int a, bool one, bool all, int pitch,
           unsigned long long numSolutions, unsigned int * d_solution,
           unsigned int * count) {
    
      // there are 2^16 possible configurations of queens on a 4x4 chessboard
      // 2^8 blocks of 2^8 threads each will check them all (brute force)
      int width = n;
      int numQueens = a;
      // TODO:
      unsigned long int blockSize = 1<<10;
            //dynamic block size for all
        unsigned long int numBlocks;
      if (all == true){
        switch (width){
          case 2:
           numBlocks= 1<<6; 

            //  n = 2   0.25 ms
          case 3:
           numBlocks= 1<<6; 


      //  n = 3   0.25 ms
        case 4:
         numBlocks= 1<<6; 

        //  n = 4   0.25 ms
        case 5:
         numBlocks= 1<<6; 

        // n = 5   0.5 ms
        case 6:

          numBlocks= 1<<6; //until n = 6   0.6 ms
        case 7:

         numBlocks= 1<<8; //until n = 7   4 ms
        case 8:

          numBlocks= 1<<13; //until n = 8   232 ms
        case 9:

          numBlocks= 1<<15; //until n = 9   756 ms
        case 10:

          numBlocks= 1<<16; //until n = 10   1 secs
        case 11:

          numBlocks= 1<<17; //until n = 11    1.2 secs
        case 12:

          numBlocks= 1<<24; //until n = 12   85 secs 
        case 13:

         numBlocks= 1<<27; //until n = 13 273 secs
        // case default:
        //  numBlocks= 1<<29; //until n = 13 273 secs

      }
      }
            //dynamic block size for one

      if (one == true){
        switch (width){
          case 2:
           numBlocks= 1<<1;
            // n = 2   0.25 ms
            case 3:
             numBlocks= 1<<1;
          //  n = 3   0.25 ms
            case 4:
             numBlocks= 1<<1;
          //  n = 4   0.25 ms
            case 5:
             numBlocks= 1<<1;
            // n = 5   0.4 ms
            case 6:

             numBlocks= 1<<1; //until n = 6   0.6 ms
            case 7:

             numBlocks= 1<<4; //until n = 7   0.9 ms
            case 8:

            numBlocks= 1<<5; //until n = 8   1 ms
            case 9:

             numBlocks= 1<<10; //until n = 9   22 ms
            case 10:

            numBlocks= 1<<14; //until n = 10   365 ms
            case 11:

             numBlocks= 1<<17; //until n = 11    856 ms
            case 12:

             numBlocks= 1<<19; //until n = 12   1.9 secs 
            case 13:

         numBlocks= 1<<24; //until n = 13     50 secs
        case 14:

         numBlocks= 1<<29; //until n = 14     325 secs

          // case default:
          //  numBlocks= 1<<30; //until n = 13  

        }
      }

  
      unsigned int *flag;
      cudaMallocManaged(&flag, sizeof(unsigned int));
      *flag = 0;

      //all combinations
      // printf("fact ");
      unsigned long long int comb = 1;
      // unsigned long long int threads;
      int m = width*width;
      int k = numQueens;
      for (int j = m ; j > m - k; j--){
            comb = comb * j;
      }
      for (int q = k; q > 0; q--){
          comb = comb / q;
      }
  
      // printf("The number of the total combinations is %llu\n", comb);

      // threads = numBlocks * blockSize;

      // printf("The number of the total threads is %llu\n", threads);

      // printf("Total threads %llu\n", threads);
      //generate every possible combinations on the memory
    

      if (all == true && one == false )
        qgdKernel<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solution, count, comb);
      else if (all == false && one == true)
        qgdKernelOne<<< numBlocks, blockSize >>>(width, numQueens, pitch, d_solution, count, comb, flag);

  }
  