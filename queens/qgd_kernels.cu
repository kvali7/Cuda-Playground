
/* thanks old college classmate Sean Anderson!
 * http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
 */

 #define BOARDSIZE 4
 #define NUMQUEENS 2
 
 __device__
int countBits(unsigned int v, int boardSize) {
    int c; // c accumulates the total bits set in v
    for (c = 0; v; v >>= 1) {
        c += v & 1;
    }
    return c;
}
 
 
 __device__
 bool checkerFunc (int* queensList,int boardSize, int numQueens){
    // int queensList[NUMQUEENS] = {2,17,22};
     bool ifCheck = true;
     //max we can do is 32 x 32
     unsigned int in_checkArr[32] ={0};
     for (int queen = 0; queen < numQueens; queen++){
         int posqueen = queensList[queen];
         int row = posqueen/boardSize;
         int col = posqueen % boardSize;
         //row easy!
         in_checkArr[row] |=  0xffffffff;
         for (int r = 0; r < boardSize; r++){
             // column in loop
             in_checkArr[r] |=  1 << col;
             // main diagon
             if (row + col - r < boardSize && row + col -r >= 0) 
                 in_checkArr[r] |=  1 << row + col - r;
             // other diagon
             if (col - row + r >= 0 && col - row + r < boardSize) 
                 in_checkArr[r] |=1 << col - row + r;
             if (countBits(in_checkArr[r], boardSize) < boardSize && queen == numQueens - 1)
                 ifCheck = false;
         }
     }
 
     return ifCheck; 
 }
 
  __global__
  void qgdKernel(int n, int a, bool one, bool all, int pitch,
                 unsigned int * d_solution, unsigned int * count) {
      // this kernel is completely hardcoded to the 4x4 board
      // I'm not pretending otherwise
  
      int tid = threadIdx.x + blockIdx.x * blockDim.x;
  
      // tid is a 16-bit number, where each bit corresponds to 1 square
      // on the chessboard.
      // a 1
  
      // strategy: look at every single possible board in parallel
      // this is very inefficient and scales extremely poorly
      // it is a bad method
      // do not do this to scale to more chessboards
  
      // we know that for n=4, a=2, so knock out all boards where a != 2
      int bitcount = countBits(tid,17);
      if (bitcount != a) { return; }
  

      // create queens List for n = 4 the size of the proposed solution is 2
     int queensList[BOARDSIZE] = {0};
     int temp = tid;
     for (int c = 0, qi = 0 ; temp ; temp >>= 1, c++){
         if (temp & 1){
             queensList[qi] = c;
             qi++;
         }
     }
     if (!checkerFunc (queensList, BOARDSIZE, NUMQUEENS)) {return;}
 
 
    //   int in_check = 0;           // start with no squares in check
    //   int loc;
    //   for (loc = 0; loc < n*n; loc++) { // iterate over possible queen locations
    //       int queen = 1 << loc;
    //       if (tid & queen) {      // there's a queen at position i
    //           // set the whole row in check
    //           int row = 0xf << (loc & 0xc);
    //           in_check |= row;
    //           // set the whole column in check
    //           int col = 0x1111 << (loc & 0x3);
    //           in_check |= col;
    //           // if we're on a diagonal, set entire diagonal
    //           if (queen & 0x2100) { in_check |= 0x2100; }
    //           if (queen & 0x4210) { in_check |= 0x4210; }
    //           if (queen & 0x8421) { in_check |= 0x8421; }
    //           if (queen & 0x0842) { in_check |= 0x0842; }
    //           if (queen & 0x0084) { in_check |= 0x0084; }
  
    //           if (queen & 0x4800) { in_check |= 0x4800; }
    //           if (queen & 0x2480) { in_check |= 0x2480; }
    //           if (queen & 0x1248) { in_check |= 0x1248; }
    //           if (queen & 0x0124) { in_check |= 0x0124; }
    //           if (queen & 0x0012) { in_check |= 0x0012; }
    //       }
    //   }
    //   if (in_check != 0xffff) { return; }
  
      // if we've reached this point, we have a valid board with configuration tid
      // printf("%x\n", tid);
  
      // claim one of the valid solutions
      int solution_id = atomicAdd(count, 1);
  
      // the below line sets solution = d_solution[solution_id]
      unsigned int * solution =
          (unsigned int *) ((char *) d_solution + solution_id * pitch);
  
      // solution is of the form [a,b] where a<b and each number
      // is an index of a queen into the 1-dimensional n*n-element chessboard
      int i, c, k;
      for (i = 0, c = tid, k = 0; c != 0; i++, c >>= 1) {
          if (c & 1) {
              solution[k++] = i;
          }
      }
  }
  
  // Store your solutions in d_solution, which has already been allocated for you
  void qgd(int n, int a, bool one, bool all, int pitch,
           unsigned long long numSolutions, unsigned int * d_solution,
           unsigned int * count) {
      if (one) {
          fprintf(stderr, "Instructor's solution only works for -all\n");
          exit(42);
      }
      if (n != 4) {
          fprintf(stderr, "Instructor's solution only works for n=4\n");
          exit(4);
      }
      if (a != 2) {
          fprintf(stderr, "Instructor's solution only works for a=2\n");
          exit(2);
      }
  
      // there are 2^16 possible configurations of queens on a 4x4 chessboard
      // 2^8 blocks of 2^8 threads each will check them all (brute force)
      qgdKernel<<< 1<<8, 1<<8 >>>(n, a, one, all, pitch, d_solution, count);
  }
  