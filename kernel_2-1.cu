#include <iostream>
#include <cstdlib>
#include <math.h>

/*
dst0 = src + 1;

dst1 = dst0 + 1;
dst1 = src + 2;

dst2 = dst1 + 1;
dst2 = dst0 + 2;
dst2 = src + 3;
*/

// Kernel function to copy the elements  
// of one array to two more arrays.
__global__
void cpy_float4(int n, float4 *src, float4 *dst0, float4 *dst1, float4 *dst2)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
    if (index > 0){
      dst0[i].x = src[i].x + src[i - 1].x;
      dst0[i].y = src[i].y + src[i - 1].y;
      dst0[i].z = src[i].z + src[i - 1].z;
      dst0[i].w = src[i].w + src[i - 1].w;
      dst1[i].x = dst0[i].x + dst0[i - 1].x;
      dst1[i].y = dst0[i].y + dst0[i - 1].y;
      dst1[i].z = dst0[i].z + dst0[i - 1].z;
      dst1[i].w = dst0[i].w + dst0[i - 1].w;
      dst2[i].x = dst1[i].x + dst1[i - 1].x;
      dst2[i].y = dst1[i].y + dst1[i - 1].y;
      dst2[i].z = dst1[i].z + dst1[i - 1].z;
      dst2[i].w = dst1[i].w + dst1[i - 1].w;
    }
    else {
      dst0[i].x = src[i].x + 0; 
      dst0[i].y = src[i].y + 0; 
      dst0[i].z = src[i].z + 0; 
      dst0[i].w = src[i].w + 0; 
      dst1[i].x = dst0[i].x + 0;
      dst1[i].y = dst0[i].y + 0;
      dst1[i].z = dst0[i].z + 0;
      dst1[i].w = dst0[i].w + 0;
      dst2[i].x = dst1[i].x + 0;
      dst2[i].y = dst1[i].y + 0;
      dst2[i].z = dst1[i].z + 0;
      dst2[i].w = dst1[i].w + 0;  
    }
  }
}

__global__
void fill_float4(int n, float4 *dst)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride){
    dst[i].x = 0;
    dst[i].y = 0;
    dst[i].z = 0;
    dst[i].w = 0;
  }
}

int main(void)
{
  int N = 1 << 20;
  float4 *x, *y, *z, *w;
  
  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N * sizeof(float4));
  cudaMallocManaged(&y, N * sizeof(float4));
  cudaMallocManaged(&z, N * sizeof(float4));
  cudaMallocManaged(&w, N * sizeof(float4));

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;

  
  // initialize x  
  fill_float4<<<numBlocks, blockSize>>>(N, x);
  
  // Run kernel on 1M elements on the GPU
  cpy_float4<<<numBlocks, blockSize>>>(N, x, y, z, w);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  double maxError0 = 0.0;
  double maxError1 = 0.0;
  double maxError2 = 0.0;
  double maxError3 = 0.0;

  for (int i = 0; i < N; i++){
    maxError0 = fmax(maxError0, fabs(y[i].x - 1.0));
    maxError1 = fmax(maxError1, fabs(y[i].y - 1.0));
    maxError2 = fmax(maxError2, fabs(y[i].z - 1.0));
    maxError3 = fmax(maxError3, fabs(y[i].w - 1.0));

    maxError0 = fmax(maxError0, fabs(z[i].x - 2.0));
    maxError1 = fmax(maxError1, fabs(z[i].y - 2.0));
    maxError2 = fmax(maxError2, fabs(z[i].z - 2.0));
    maxError3 = fmax(maxError3, fabs(z[i].w - 2.0));
    
    maxError0 = fmax(maxError0, fabs(w[i].x - 3.0));
    maxError1 = fmax(maxError1, fabs(w[i].y - 3.0));
    maxError2 = fmax(maxError2, fabs(w[i].z - 3.0));
    maxError3 = fmax(maxError3, fabs(w[i].w - 3.0));
  }
  std::cout << "Max error0: " << maxError0 << std::endl;
  std::cout << "Max error1: " << maxError1 << std::endl;
  std::cout << "Max error2: " << maxError2 << std::endl;
  std::cout << "Max error3: " << maxError3 << std::endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);
  cudaFree(z);
  cudaFree(w);

  return 0;
}
