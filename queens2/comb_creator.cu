
__device__
unsigned long long int combin(int m, int k) {
    unsigned long long int comb = 1;
    for (int j = m; j > m - k; j--) {
        comb = comb * j;
    }
    for (int q = k; q > 0; q--) {
        comb = comb / q;
    }
    return comb;
}

__device__
void queenGen(unsigned int* queensList, unsigned long long int i, int m, int k) {
    //lexico
    int q = 0;
    i  = i + 1;
    int j = 0;
    for (int s = 1; s < k + 1; s++) {
        int cs = j + 1;
        unsigned long long int com = combin(m - cs, k - s);
        while (i > com) {
            i -= com;
            cs += 1;
            com = combin(m - cs, k - s);
        }
        queensList[q++] = cs - 1;
        j = cs;
    }
}

