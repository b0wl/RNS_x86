#return array of base-system words
def radix(x, base):
    digits = []

    while x:
        digits.append(int(x % base))
        x /= int(base)

    digits.reverse()
    return digits

# ax + by = gcd(a, b)
def egcd(a, b):
    x0, x1, y0, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0


# Multiplicative inverse 1/d mod n
def mulinv(d, n):
    g, x, _ = egcd(d, n)
    if g == 1:
        return x % n


def ADD(t, i, C, W):
    for j in range(i, len(t)):
        if C:
            double_word = t[j] + C
            t[j] = double_word % W
            C = double_word // W
        else:
            return t

#Montgomery Multiplication Separate Operand Scanning
def MonProSOS(a, b, s, w, n):
    k = s * w
    W = 2 ** w
    r = 2 ** k
    r_p = mulinv(r, n)  # r prim
    n_p = mulinv(r-n, r)
    n0 = n_p % W

    print('a := ' + str(a))
    print('b := ' + str(b))
    print('r := ' + str(r))
    print('n := ' + str(n))

    print('n\' := ' + str(n_p))
    print('r\' := ' + str(r_p))

    a_d = (a * r) % n
    b_d = (b * r) % n

    print('a^ := ' + str(a_d))
    print('b^ := ' + str(b_d))

    aT = radix(a, W)[-s:][::-1]
    bT = radix(b, W)[-s:][::-1]
    print('aT = ' + str(aT))
    print('bT = ' + str(bT))
    nT = radix(n, W)[-s:][::-1]

    # n0 = mulinv(nT[0], r) % W

    print('n0 := ' + str(n0))
    print('nT = ' + str(nT))

    # Step 1

    t = [0]*(2*s)
    for i in range(s):
        C = 0
        for j in range(s):
            double_word = t[i + j] + aT[j] * bT[i] + C
            C, S = double_word // W, double_word % W
            t[i + j] = S
        t[i + s] = C

    # check
    temp = 0
    for i, w in enumerate(t):
        temp += w*W**i
    print('Step 1:')
    print('t := ' + str(temp))

    # Step 2

    t = t + [0]
    C2 = 0
    for i in range(s):
        C = 0
        m = (t[i] * n0) % W
        for j in range(s):
            double_word = t[i + j] + m * nT[j] + C
            C, S = double_word // W, double_word % W
            t[i + j] = S
        #print(t, C, i + s)
        t = ADD(t, i + s, C, W)
        # Same effect as ADD...
        # double_word = t[i + s] + C + C2
        # t[i + s] = double_word % W
        # C2 = double_word // W
        #print(t, '\n---------')

    u = t[s:]
    print(u, len(u))
    print(t, len(t))

    # check
    temp = 0
    for i, w in enumerate(u):
        temp += w*W**i
    print('Step 2:')
    print('u := ' + str(u))
    print('u := ' + str(temp))

    # Step 3
    return step3(u,nT,W,t[-s-1:])


def MonProCIOS(a, b, s, w, n):
    k = s * w
    W = 2 ** w
    r = 2 ** k
    r_p = mulinv(r, n)  # r prim
    n_p = mulinv(r-n, r)
    n0 = n_p % W

    print('a := ' + str(a))
    print('b := ' + str(b))
    print('r := ' + str(r))
    print('n := ' + str(n))

    print('n\' := ' + str(n_p))
    print('r\' := ' + str(r_p))

    a_d = (a * r) % n
    b_d = (b * r) % n

    print('a^ := ' + str(a_d))
    print('b^ := ' + str(b_d))

    aT = radix(a, W)[-s:][::-1]
    bT = radix(b, W)[-s:][::-1]
    print('aT = ' + str(aT))
    print('bT = ' + str(bT))
    nT = radix(n, W)[-s:][::-1]

    # n0 = mulinv(nT[0], r) % W

    print('n0 := ' + str(n0))
    print('nT = ' + str(nT))

    t = [0]*(s+2)
    for i in range(s):
        C = 0
        for j in range(s):
            double_word = t[j] + aT[j]*bT[i] + C
            C, S = double_word // W, double_word % W
            t[j] = S
        double_word = t[s] + C
        C, S = double_word // W, double_word % W
        t[s] = S
        t[s + 1] = C
        C = 0
        m = (t[0] * n0) % W
        for j in range(s):
            double_word = t[j] + m * nT[j] + C
            C, S = double_word // W, double_word % W
            t[j] = S
        double_word = t[s] + C
        C, S = double_word // W, double_word % W
        t[s] = S
        t[s + 1] = t[s + 1] + C
        for j in range(s+1):
            t[j] = t[j+1]

    u = t
    u.pop()
    # check
    temp = 0
    for i, w in enumerate(u):
        temp += w*W**i

    print('tT := ' + str(t))
    print('tT := ' + str(u))
    print('u := ' + str(temp))

    # Step 3
    return step3(u,nT,W,t)


def step3(u,nT,W,t):    
    print('Step 3:')   
    print(str(u))     
    print(str(nT))   
    print(str(W))   
    print(str(t[-s:])) 
    B = 0
    for i in range(s):
        double_word = u[i] - nT[i] - B
        B, D = double_word // W, double_word % W
        t[i] = D
    double_word = u[s] - B
    B, D = double_word // W, double_word % W
    t[s] = D
    if B:
        cT = t[:s]
    else:
        cT = u[:s]

    c = 0
    for i, w in enumerate(cT):
        c += w*W**i


    print('result := ' + str(c))
    return c


if __name__ == '__main__':
    a = 100
    b = 240
    s = 4
    w = 4
    n = 33533
    print('SOS------------')
    c = MonProSOS(a, b, s, w, n)
    print('CIOS-----------')
    a = 100
    b = 240
    s = 4
    w = 4
    n = 33533
    c = MonProCIOS(a, b, s, w, n)
