#include <iostream>
#include <stdio.h>
#include "checker_helper.cu"

#define BLOCK_SIZE 4
#define NUM_BLOCKS 4
#define GLOBAL_BUF_SIZE 16384
#define INTERNAL_BUF_SIZE BLOCK_SIZE

__device__ volatile int globalHead;
__device__ volatile int globalTail;
__device__ volatile int blockFence;
// __device__ volatile int tailSem = 0;
// __device__ volatile int headSem = 0;

// __device__ void acquire_semaphore(volatile int *lock){
//     while (atomicCAS((int *) lock, 0, 1) != 0);
// }

// __device__ void release_semaphore(volatile int *lock){
//     *lock = 0;
//     __threadfence();
// }


__global__ void initialize(int *buffer, int width, size_t pitch){
    globalHead = 0;
    globalTail = 0;
    blockFence = 0;
    int numQueens = 5;
    for (int i = 0; i < ceilf(width / 2); ++i)
        for (int j = 0; j < ceilf(width / 2); ++j){
            int *row = (int*) ((char*) buffer + (globalTail++) * pitch);
            row[0] = i * width + j;
            // printf("globalTail: %4d\telement: %4d\n", globalTail, row[0]);
        }
    for (int i = 0; i < width * width; ++i){
        int *row = (int*) ((char*) buffer + i * pitch);
        for (int q = 0; q < numQueens; ++q){
            printf("%4d\t", row[q]);
        }
        printf("\n");
        row[0] = 2;
        row[1] = 20;
        row[2] = 11;
        row[3] = 30;
        row[4] = 60;
        if (!checkerFunc (row, width, numQueens)) {printf("this is Not a Solution!\n");}
        row[0] = 27;
        row[1] = 33;
        row[2] = 56;
        row[3] = 4;
        row[4] = 55;
        if (!checkerFunc (row, width, numQueens)) {printf("s2 is Not a Solution!\n");}
    }
    
}
 
__global__ void qgdKernel(int width, size_t pitch, int numQueens, int *globalBuffer){

    int globalIndex = threadIdx.x + blockIdx.x * blockDim.x;
    int internalIndex = threadIdx.x; 
    int blockIndex = blockIdx.x;

    __shared__ int internalBuffer[16][INTERNAL_BUF_SIZE];
    __shared__ int internalHead;
    __shared__ int internalTail;

    if (internalIndex == 0){
        internalHead = 0;
        internalTail = 0;
    }
    __syncthreads();

    for (int i = 0; i < 16; ++i)
        internalBuffer[i][internalIndex] = -1;

    __syncthreads();
    while(globalHead < globalTail){
        if (internalIndex == 0){
            while(blockFence != blockIndex);
            while(true){
                if (internalTail == INTERNAL_BUF_SIZE)
                    break;
                if (globalHead == globalTail)
                    break;
                
                int *row = (int *)((char *) globalBuffer + globalHead * pitch);
                for (int i = 0; i < numQueens; ++i){
                    internalBuffer[i][internalTail] = row[i];
                    row[i] = -1;
                }
                ++internalTail;
                ++globalHead;
                if (globalHead == globalTail){
                    globalHead = 0;
                    globalTail = 0;
                }
            }
            if (++blockFence == NUM_BLOCKS)
                blockFence = 0;
        }
        __syncthreads();
        if (internalIndex == 0){
            while(blockFence != blockIndex);
            while(true){
                if (globalTail == GLOBAL_BUF_SIZE)
                    break;
                if (internalHead == internalTail){
                    internalHead = 0;
                    internalTail = 0;
                    break;
                }
                
                int *row = (int *)((char *) globalBuffer + globalTail * pitch);
                for (int i = 0; i < numQueens; ++i){
                    row[i] = internalBuffer[i][internalHead];
                    internalBuffer[i][internalHead] = -1;
                }
                ++internalHead;
                ++globalTail;
                if (internalHead == internalTail){
                    internalHead = 0;
                    internalTail = 0;
                }
            }
            if (++blockFence == NUM_BLOCKS)
                blockFence = 0;
        }
        __syncthreads();

        break;
    }
}

int main(void){
    int width = 8;
    int numQueens = 5;

    int *buffer;
    size_t pitch;

    cudaMallocPitch((void**) &buffer, &pitch, numQueens * sizeof(int), width * width);
    cudaMemset2D(buffer, pitch, 255, numQueens * sizeof(int), width * width);
    
    initialize<<< 1, 1 >>>(buffer, width, pitch);
    cudaDeviceSynchronize();
    qgdKernel<<< 4, 4 >>>(width, pitch, numQueens, buffer);
    cudaDeviceSynchronize();

    cudaFree(buffer);
}
 
 