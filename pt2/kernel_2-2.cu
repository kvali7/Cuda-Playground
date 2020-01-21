#include <iostream>
#include <cstdlib>
#include <math.h>

using namespace std; 

__global__
void p_vec_dist(int dim, float3 p, float3 *vec, float *res){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < dim; i += stride){
        res[i] = (p.x - vec[i].x) * (p.x - vec[i].x);   
        res[i] += (p.y - vec[i].y) * (p.y - vec[i].y);
        res[i] += (p.z - vec[i].z) * (p.z - vec[i].z);
    }
}

__global__
void vec_vec_dist(int dim, float3 *vec0, float3 *vec1, float *res){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < dim; i += stride){
        //p_vec_dist<<<1, dim>>>(dim, vec0[i], vec1, res[i]);
        for (int j = 0; j < dim; j++){
            res[i] = (vec0[i].x - vec1[j].x) * (vec0[i].x - vec1[j].x);
            res[i] += (vec0[i].y - vec1[j].y) * (vec0[i].y - vec1[j].y);
            res[i] += (vec0[i].z - vec1[j].z) * (vec0[i].z - vec1[j].z);   
        }
    }
}

__global__
void fill_float3(int dim, float3 val, float3 *dst)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < dim; i += stride){
    dst[i].x = val.x;
    dst[i].y = val.y;
    dst[i].z = val.z;
  }
}

int main(void){
    int dim = 1 << 10;
    float3 *x, *y; 
    float *res; 

    cudaMallocManaged(&x, dim * sizeof(float3));
    cudaMallocManaged(&y, dim * sizeof(float3));
    cudaMallocManaged(&res, dim * sizeof(float));

    fill_float3<<<32, 32>>>(dim, make_float3(1.0, 2.0, 3.0), x);
    fill_float3<<<32, 32>>>(dim, make_float3(4.0, 5.0, 6.0), y);

    vec_vec_dist<<<32, 32>>>(dim, x, y, res);

    float maxError = 0.0;
    for (int i = 0; i < dim; i++)
        for (int j = 0; j < dim; j++)
            maxError = fmax(maxError, fabs(res[i] - 0.0f));
    cout << "Max error: " << maxError << endl;

    cudaFree(x);
    cudaFree(y);
    cudaFree(res);
    return 0;
}