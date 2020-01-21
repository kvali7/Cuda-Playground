#include <iostream>
#include <math.h>

typedef struct 
{
  double x;
  double y;
  double z;
  double w;
  double xx;
  double yy;
  double zz;
  double ww;
} double8;

// Kernel function to add the elements of two arrays
__global__
void cpy_double8(int n, double8 *src, double8 *dst)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
    dst[i].x = src[i].x + 1;
    dst[i].y = src[i].y + 1;
    dst[i].z = src[i].z + 1;
    dst[i].w = src[i].w + 1;
    dst[i].xx = src[i].xx + 1;
    dst[i].yy = src[i].yy + 1;
    dst[i].zz = src[i].zz + 1;
    dst[i].ww = src[i].ww + 1;
  }
}

__global__
void fill_double8(int n, double8 *dst)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
    dst[i].x = 0;
    dst[i].y = 0;
    dst[i].z = 0;
    dst[i].w = 0;
    dst[i].xx = 0;
    dst[i].yy = 0;
    dst[i].zz = 0;
    dst[i].ww = 0;
  }
}

int main(void)
{
  int N = 1 << 20;
  double8 *x, *y, *z;
  
  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N * sizeof(double8));
  cudaMallocManaged(&y, N * sizeof(double8));
  cudaMallocManaged(&z, N * sizeof(double8));

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;

  /*
  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }
  */
  //fill_double8<<<numBlocks, blockSize>>>(N, x);
  
  /*
  // Run kernel on 1M elements on the GPU
  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;
  add<<<numBlocks, blockSize>>>(N, x, y);
  */
  cpy_double8<<<numBlocks, blockSize>>>(N, x, y);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  // Copying to host memory 
  cudaMemcpy(z, y, N * sizeof(double8), cudaMemcpyDeviceToHost);

  double maxError = 0.0;
  for (int i = 0; i < N; i++){
    maxError = fmax(maxError, fabs(z[i].x - 1.0));
    maxError = fmax(maxError, fabs(z[i].y - 1.0));
    maxError = fmax(maxError, fabs(z[i].z - 1.0));
    maxError = fmax(maxError, fabs(z[i].w - 1.0));
    maxError = fmax(maxError, fabs(z[i].xx - 1.0));
    maxError = fmax(maxError, fabs(z[i].yy - 1.0));
    maxError = fmax(maxError, fabs(z[i].zz - 1.0));
    maxError = fmax(maxError, fabs(z[i].ww - 1.0));
  }
  std::cout << "Max error: " << maxError << std::endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);
  free(z);
  return 0;
}
