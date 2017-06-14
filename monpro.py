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

# Propagate carry
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
    n_p = mulinv(r-n, r)
    n0 = n_p % W

    aT = radix(a, W)[-s:][::-1]
    bT = radix(b, W)[-s:][::-1]
    nT = radix(n, W)[-s:][::-1]

    # Step 1
    t = [0]*(2*s)
    for i in range(s):
        C = 0
        for j in range(s):
            double_word = t[i + j] + aT[j] * bT[i] + C
            C, S = double_word // W, double_word % W
            t[i + j] = S
        t[i + s] = C

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

        t = ADD(t, i + s, C, W)
    u = t[s:]

    # Step 3
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
    return c


def MonProCIOS(a, b, s, w, n):
    k = s * w
    W = 2 ** w
    r = 2 ** k
    n_p = mulinv(r-n, r)
    n0 = n_p % W

    aT = radix(a, W)[-s:][::-1]
    bT = radix(b, W)[-s:][::-1]
    nT = radix(n, W)[-s:][::-1]

    t = [0]*(s+2)
    # Steps 1 and 2
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

    # Step 3
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

    # Compute value of result
    c = 0
    for i, w in enumerate(cT):
        c += w * W ** i
    return c

if __name__ == '__main__':
    a = 100
    b = 240
    s = 4
    w = 4
    n = 33533
    c = MonProSOS(a, b, s, w, n)
    c = MonProCIOS(a, b, s, w, n)
