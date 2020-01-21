#include <iostream>
#include <math.h>
//#include <cuda_runtime.h>

// function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  //int index = 0;
  //int stride = 1;
  //int index = threadIdx.x;
  //int stride = blockDim.x;
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride)
      y[i] = x[i] + y[i];
}

//__global__
//void init(int n, float* x, float* y){
//
//  int index = blockIdx.x * blockDim.x + threadIdx.x;
//  int stride = blockDim.x * gridDim.x;
//  for (int i = index; i < n; i += stride){
//     x[i] = 1.0f;
//     y[i] = 2.0f;
//  }
//}

int main(void)
{
  int N = 1<<20; // 1M elements

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;

  //variable defition on system memory
  //float *x = new float[N];
  //float *y = new float[N];
 
  float *x, *y;
  //variable allocation on GPU memory
  cudaMallocManaged (&x, N*sizeof(float));
  cudaMallocManaged (&y, N* sizeof(float));



  
  // initialize x and y arrays on the host
  //for (int i = 0; i < N; i++) {
  //  x[i] = 1.0f;
  //  y[i] = 2.0f;
  //}
  //init<<<numBlocks, blockSize>>>(N, x, y);


  // Prefetch the data to the GPU
  int device = -1;
  cudaGetDevice(&device);
  cudaMemPrefetchAsync(x, N*sizeof(float), device, NULL);
  cudaMemPrefetchAsync(y, N*sizeof(float), device, NULL);

  // Run kernel on 1M elements on the CPU
  //add(N, x, y);
  
  // Run kernel on 1M parallel elements on the GPU  
  //add<<<1,256>>>(N, x, y);
  // Multiple blocks
  add<<<numBlocks, blockSize>>>(N, x, y);

  // wait for the GPU to finish the results
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  std::cout << "Max error: " << maxError << std::endl;

  // Free memory
  //delete [] x;
  //delete [] y;
  
  // Free GPU memory
  cudaFree(x);
  cudaFree(y);


  
  return 0;
}
