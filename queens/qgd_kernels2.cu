#include "comb_creator.cu"
#include "checker_helper.cu"

__global__
void qgdKernelOne(int width, int numQueens, int pitch,
    unsigned int* d_solution, unsigned int* count, unsigned long long int maxit, unsigned int* flag) {

    unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    // create queens List of max size 16
        unsigned int queensList[16] = {0};

    for (unsigned long long int id = tid; id < maxit; id += stride){

        if (*flag) return;

        queenGen (queensList, id, width * width, numQueens); // with for loop
        if (!checkerFunc (queensList, width, numQueens) ) {continue;} // with for loop

        // queenGen (queensList, tid, width * width, numQueens); // without for loop
        // if (!checkerFunc (queensList, width, numQueens)) {return;} // without for loop

          addtoSolution (queensList,  numQueens, d_solution, count, pitch);
          int valflag = atomicAdd(flag, 1);
          printf("flag = %d\n",valflag);

    }
  
}

__global__
void qgdKernel(int width, int numQueens, int pitch,
      unsigned int* d_solution, unsigned int* count, unsigned long long int maxit) {


    unsigned long long int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;
        // create queens List of max size 16
        unsigned int queensList[16] = {0};

    for (unsigned long long int id = tid; id < maxit; id += stride){
        
        // queenGen (queensList, tid, width * width, numQueens); // without for loop
        // if (!checkerFunc (queensList, width, numQueens)) {return;} // without for loop

        queenGen (queensList, id, width * width, numQueens); // with for loop
        if (!checkerFunc (queensList, width, numQueens)) {continue;} // with for loop


          addtoSolution (queensList,  numQueens, d_solution, count, pitch);

    }
    
}

// Store your solutions in d_solution, which has already been allocated for you
void qgd(int width, int numQueens, bool one, bool all, int pitch,
    unsigned long long numSolutions, unsigned int* d_solution,
    unsigned int* count) {


    unsigned int* flag;
    cudaMallocManaged(&flag, sizeof(unsigned int));
    *flag = 0;

    //all combinations
    unsigned long long int comb = 1;
    int m = width * width;
    int k = numQueens;
    for (int j = m; j > m - k; j--) {
        comb = comb * j;
    }
    for (int q = k; q > 0; q--) {
        comb = comb / q;
    }


    unsigned long int blockSize;

    if (width < 7)
        blockSize = 1 << 8;
    else
      //// for RTX 2080 ti and K40 1024 max thread
      // blockSize = 1 << 9;
      ////for titan xp 2048 max thread
      blockSize = 1 << 10;       
      
      
    //dynamic block size for all
    unsigned long int numBlocks;

    // unsigned long long int numBlocksAllTable[] = {
    //   1 << 2, 1 << 2, 1 << 2, 1 << 2, 1 << 2, 1 << 2, 1 << 6, 1 << 8, 1 << 13, 1 << 15, 1 << 16,  1 << 17, 1 << 24, 1 << 27 };

    unsigned long  int numBlocksOneTable[] = {
      1, 1, 1, 1, 1, 1, 50, 8 , 20, 700, 2000, 2000,  2000 , 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000 };



    unsigned long long int maxit = comb;
    if (all == true){
        numBlocks = comb / blockSize + 4;
    }
    else{
        numBlocks = numBlocksOneTable[width];
        if (width == 12)
          maxit = 309000000;
    }
   
    // if (numBlocks < 1)
    //   numBlocks = 1;
    // if (all == true){


// titan xp
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
    // n = 12   70 secs 
    // n = 13  273 secs

    // if (one == true){
    // n = 2   0.27
    //  n = 3   0.32
    //   n = 4   0.33
    //  n = 5   0.4 ms
    // n = 6   0.8 ms
    //  n = 7   0.8 ms
    //   n = 8   1.5 ms
    //   n = 9   80 ms
    //  n = 10   365 ms
    //   n = 11    856 ms
    //     n = 12   1.6 secs 
    //   n = 13     4 secs
    //  n = 14     325 secs

    //// in k40 240 = 16* 15 SMs
    // if (numBlocks > 480)
    //   numBlocks = 480;
    //// in titan xp = 32* 30 SMs
    if (numBlocks > 2000)
      numBlocks = 2000;
    //// in rtx 2080 ti = 16* 68 SMs
    // if (numBlocks > 2200)
    //   numBlocks = 2200;

    // blockSize = 256;
    // numBlocks = 4;


    // maxit = 7000;
    // blockSize = 256;
    // numBlocks = 10;

    printf("The number of the total combinations is %llu\n", comb);
     unsigned long long int threads;
    threads = numBlocks * blockSize;
    printf("maxit = %llu, thread = %d, blocks = %d The number of the total threads is %llu\n", maxit, blockSize, numBlocks, threads);



    if (all == true){

        qgdKernel <<< numBlocks, blockSize >>> (width, numQueens, pitch, d_solution, count, maxit);
    }
    else {

        qgdKernelOne <<< numBlocks, blockSize >> > (width, numQueens, pitch, d_solution, count, maxit, flag);
    }

}
