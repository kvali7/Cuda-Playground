#include <iostream>
#include <math.h>
//#include <cuda_runtime.h>


// function to copy the elements of an array and decrement to make the compiler not override it
__global__
void copyKernel(int n, float4* x, float4* y, float4* z, float4* w){

  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
      y[i].x = x[i].x - 1.0;
      y[i].y = x[i].y - 1.0;
      y[i].z = x[i].z - 1.0;
      y[i].w = x[i].w - 1.0;
      z[i].x = y[i].x - 1.0;
      z[i].y = y[i].y - 1.0;
      z[i].z = y[i].z - 1.0;
      z[i].w = y[i].w - 1.0;
      w[i].x = z[i].x - 1.0;
      w[i].y = z[i].y - 1.0;
      w[i].z = z[i].z - 1.0;
      w[i].w = z[i].w - 1.0;
  }
}

__global__
void init(int n, float4* x, float val){

  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
     x[i].x = val;
     x[i].y = val;
     x[i].z = val;
     x[i].w = val;
  }
}



int main(int argc,char* argv[]){

  int N = 1<<20;

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;

  if (argc >= 2)
     blockSize = atoi(argv[1]);

  if (argc >= 3)
     numBlocks = atoi(argv[2]);
  
  std::cout<<"blockSize= "<<blockSize<<std::endl;
  std::cout<<"numBlocks= "<<numBlocks<<std::endl;
 
  float4 *x, *y, *z, *w;
  //variable allocation on GPU memory
  cudaMallocManaged (&x, N*sizeof(float4));
  cudaMallocManaged (&y, N* sizeof(float4));
  cudaMallocManaged (&z, N*sizeof(float4));
  cudaMallocManaged (&w, N* sizeof(float4));
  
  // initialize x and y arrays on the device
  float val = 3.0f;
  init<<<numBlocks, blockSize>>>(N, x, val);
  
  // Run kernel on 1M parallel elements on the GPU  
  copyKernel<<<numBlocks, blockSize>>>(N, x, y, z, w);

  // wait for the GPU to finish the results
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++){
    maxError = fmax(maxError, fabs(y[i].x - 2.0f));
    maxError = fmax(maxError, fabs(y[i].y - 2.0f));
    maxError = fmax(maxError, fabs(y[i].z - 2.0f));
    maxError = fmax(maxError, fabs(y[i].w - 2.0f));
    maxError = fmax(maxError, fabs(z[i].x - 1.0f));
    maxError = fmax(maxError, fabs(z[i].y - 1.0f));
    maxError = fmax(maxError, fabs(z[i].z - 1.0f));
    maxError = fmax(maxError, fabs(z[i].w - 1.0f));
    maxError = fmax(maxError, fabs(w[i].x - 0.0f));
    maxError = fmax(maxError, fabs(w[i].y - 0.0f));
    maxError = fmax(maxError, fabs(w[i].z - 0.0f));
    maxError = fmax(maxError, fabs(w[i].w - 0.0f));
}
  std::cout << "Max error: " << maxError << std::endl;

  // Free GPU memory
  cudaFree(x);
  cudaFree(y);
  cudaFree(z);
  cudaFree(w);


  return 0;
}
