


def C(n,k): #computes nCk, the number of combinations n choose k
    result = 1
    for i in range(n):
        result*=(i+1)
    for i in range(k):
        result/=(i+1)
    for i in range(n-k):
        result/=(i+1)
    return result

def cgen(i,n,k):
    """
    returns the i-th combination of k numbers chosen from 1,2,...,n
    """
    c = []
    r = i+1
    j = 0
    for s in range(1,k+1):
        cs = j+1
        print(r)
        while r-C(n-cs,k-s)>0:
            r -= C(n-cs,k-s)
            cs += 1
        c.append(cs-1)
        j = cs
    return c



print (cgen(0,16,2))