#include <iostream>
#include <math.h>
//#include <cuda_runtime.h>


// function to copy the elements of an array and decrement to the compiler not override it
__global__
void newtonKernel(int n, float4* x, float4* y, float4* z){
	float4 result = make_float4 (1.0f,1.0f,1.0f,1.0f);
        int index = blockIdx.x * blockDim.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;
        for (int i = index; i < n; i += stride){

		for (int k =0; k < 40; k++){
			result.x = result.x * k * x[i].x * y[i].x + x[i].x + y[i].x;
			result.y = result.y * k * x[i].y * y[i].y + x[i].y + y[i].y;
			result.z = result.z * k * x[i].z * y[i].z + x[i].z + y[i].z;
			result.w = result.w * k * x[i].w * y[i].w + x[i].w + y[i].w;
		}
	      z[i] = result  ;
	      y[i].x = z[i].x ;
	      y[i].y = z[i].y ;
	      y[i].z = z[i].z ;
	      y[i].w = z[i].w ;
	      x[i].x = y[i].x ;
	      x[i].y = y[i].y ;
	      x[i].z = y[i].z ;
	      x[i].w = y[i].w ;

  	}
}


int main(void){

  int N = 1<<20;

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;
 
  float4 *x, *y, *z;
  //variable allocation on GPU memory
  cudaMallocManaged (&x, N*sizeof(float4));
  cudaMallocManaged (&y, N* sizeof(float4));
  cudaMallocManaged (&z, N*sizeof(float4));

  
  // initialize x and y arrays on the device
  //float val = 3.0f;

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = make_float4(1.0f,1.0f,1.0f, 1.0f);
    y[i] = make_float4(2.0f,2.0f,2.0f, 2.0f);
    z[i] = make_float4(1.0f,1.0f,1.0f, 1.0f);;
  }

  // Run kernel on 1M parallel elements on the GPU  
  newtonKernel<<<numBlocks, blockSize>>>(N, x, y, z);

  // wait for the GPU to finish the results
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++){
   maxError = fmax(maxError, fabs(x[i].x - 1.0f));
    maxError = fmax(maxError, fabs(x[i].y - 1.0f));
    maxError = fmax(maxError, fabs(x[i].z - 1.0f));
    maxError = fmax(maxError, fabs(x[i].w - 1.0f));
   maxError = fmax(maxError, fabs(y[i].x - 1.0f));
    maxError = fmax(maxError, fabs(y[i].y - 1.0f));
    maxError = fmax(maxError, fabs(y[i].z - 1.0f));
    maxError = fmax(maxError, fabs(y[i].w - 1.0f));
    maxError = fmax(maxError, fabs(z[i].x - 1.0f));
    maxError = fmax(maxError, fabs(z[i].y - 1.0f));
    maxError = fmax(maxError, fabs(z[i].z - 1.0f));
    maxError = fmax(maxError, fabs(z[i].w - 1.0f));
}
  std::cout << "Max error: " << maxError << std::endl;

  // Free GPU memory
  cudaFree(x);
  cudaFree(y);
  cudaFree(z);



  return 0;
}
