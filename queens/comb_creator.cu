__device__ //mCk
int combin(int m, int k) {
    unsigned long int comb = 1;
    if (m > 0 && k > 0) {
        for (int j = m; j > m - k; j--) {
            comb = comb * j;
        }
        for (int q = k; q > 0; q--) {
            comb = comb / q;
        }
    }
    return comb;
}

__device__
void queenGen(unsigned int* queensList, unsigned long long int i, int m, int k) {
    int q = 0;
    unsigned long long int r = i + 1;
    int j = 0;
    for (int s = 1; s < k + 1; s++) {
        int cs = j + 1;
        int com = combin(m - cs, k - s);
        while (r > com) {
            r -= com;
            cs += 1;
            com = combin(m - cs, k - s);
        }
        queensList[q++] = cs - 1;
        j = cs;
    }
}

