#include <stdlib.h>
#include <stdio.h>
#include <string.h>


// includes, project
#include <cuda.h>
#include <cuda_runtime.h>

#include "qgd_kernels2.cu"

// #define BOARDSIZE 4
// #define NUMQUEENS 2

// #define ALL 1
// #define ONE 0

#define CUDA_SAFE_CALL_NO_SYNC( call) do {                              \
    cudaError err = call;                                                 \
    if( cudaSuccess != err) {                                             \
      fprintf(stderr, "Cuda error in file '%s' in line %i : %s.\n",       \
                  __FILE__, __LINE__, cudaGetErrorString( err) );         \
      exit(EXIT_FAILURE);                                                 \
      } } while (0)
  
  #define CUDA_SAFE_CALL( call) do {                                      \
    CUDA_SAFE_CALL_NO_SYNC(call);                                         \
    cudaError err = cudaDeviceSynchronize();                              \
    if( cudaSuccess != err) {                                             \
       fprintf(stderr, "Cuda error in file '%s' in line %i : %s.\n",      \
                   __FILE__, __LINE__, cudaGetErrorString( err) );        \
       exit(EXIT_FAILURE);                                                \
       } } while (0)
  
  void usage(char** argv) {
      fprintf(stderr, "Usage: %s -{one,all} n a\n", argv[0]);
      exit(1);
  }
  
  unsigned long long solutionsTable[] = {
    0, 1, 4, 1, 12, 186, 4, 86, 4860, 114, 8, 2, 8, 288, 500, 500 , 500, 500 , 500, 500, 500, 500
    // https://oeis.org/A002564   (this is a(n))
    // we have no numbers past this, please post them as you find them
    // you will need to fill in this array as n gets bigger
};
  
  int main(int argc, char** argv) {
  
  
      //args
        if (argc != 4) {
            usage(argv);
        }
        bool one = false;
        bool all = false;
        if (!strcmp(argv[1], "-one")) {
            one = true;
        }
        if (!strcmp(argv[1], "-all")) {
            all = true;
        }
        if (!one && !all) {
            usage(argv);
        }
        int n = atoi(argv[2]);
        int a = atoi(argv[3]);
  
      unsigned long long numSolutions = solutionsTable[n];
  
      cudaEvent_t start, stop;
      cudaEventCreate(&start);
      cudaEventCreate(&stop);
  
      // allocate memory
      unsigned int* h_solutions;
      h_solutions = (unsigned int*)malloc(numSolutions * a * sizeof(unsigned int));
      unsigned int* d_solutions;
      unsigned int* count;
      cudaMallocManaged(&count, sizeof(unsigned int));
      *count = 0;
      size_t dpitch;
      // height is number of solutions
      // width is items per solution
      CUDA_SAFE_CALL(cudaMallocPitch(&d_solutions, &dpitch,
          a * sizeof(unsigned int),
          numSolutions));
      float elapsedTime;
      cudaDeviceSynchronize();
      cudaEventRecord(start, 0);
      qgd(n, a, one, all, dpitch, numSolutions, d_solutions, count);
      cudaEventRecord(stop, 0);
      cudaEventSynchronize(stop);
      cudaEventElapsedTime(&elapsedTime, start, stop);
  
      size_t hpitch = a * sizeof(unsigned int);
  
      CUDA_SAFE_CALL(cudaMemcpy2D(h_solutions, hpitch, d_solutions, dpitch,
          a * sizeof(unsigned int), // width
          numSolutions,                // height
          cudaMemcpyDeviceToHost));
  
      cudaEventDestroy(start);
      cudaEventDestroy(stop);

    //   unsigned long long int valcount;


    //   // print answers
      int maxi = 0;
      if (all == true && one ==false)
        maxi = numSolutions;
      else
        maxi = 1;

        for (int i = 0; i < maxi; i++) {
            unsigned int* solution = &h_solutions[i * a];
            // i is which solution
            printf("Solution %d is [", i);
            for (int k = 0; k < a; k++) {
                printf("%d%s", solution[k], (k < a - 1) ? ", " : "]");
            }
            for (int j = 0, k = 0; j < n * n; j++) {
                // j is which square of the chessboard (note each solution
                // must be in sorted order)
                // k is which queen we're placing (also index into the soln. array)
                if (j % n == 0) {
                    printf("\n");
                }
                if (j == solution[k] && k < a) {
                    printf("Q");
                    k++;
                }
                else {
                    printf(".");
                }
            }
            printf("\n");
        }


        if (*count == numSolutions)
        printf("All %llu solutions found!\n", numSolutions);
    else
        printf("Only %u solutions\n", *count);
  
        printf("Processing time: %f (ms)\n", elapsedTime);

  
      // clean up memory
      free(h_solutions);
      CUDA_SAFE_CALL(cudaFree(d_solutions));
      cudaFree(count);
  }
  