#include <iostream>
#include <math.h>

// function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  //int index = 0;
  //int stride = 1;
  int index = threadIdx.x;
  int stride = blockDim.x;
  for (int i = index; i < n; i += stride)
      y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 1<<20; // 1M elements

  //variable defition on system memory
  //float *x = new float[N];
  //float *y = new float[N];
 
  float *x, *y;
  //variable allocation on GPU memory
  cudaMallocManaged (&x, N*sizeof(float));
  cudaMallocManaged (&y, N* sizeof(float));



  
  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  // Run kernel on 1M elements on the CPU
  //add(N, x, y);
  
  // Run kernel on 1M parallel elements on the GPU  
  add<<<1,256>>>(N, x, y);

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
