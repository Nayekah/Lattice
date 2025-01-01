from Crypto.Util.number import getPrime, GCD
from pesanrahasia import FLAG
import random

def egcd(a, b):
    r0, r1 = a, b
    s0, s1 = 1, 0
    t0, t1 = 0, 1
    while r1 > 0:
        q = r0 // r1
        r0, r1 = r1, r0 % r1
        s0, s1 = s1, s0 - q * s1
        t0, t1 = t1, t0 - q * t1
    return s0, t0

def generateKey():
    p = getPrime(512)
    q = getPrime(512)
    n = p * q
    phi = (p-1)*(q-1)

    while True:
        d1 = getPrime(int(n.bit_length()*0.16))
        e1 = random.randint(1, phi)
        ed1 = e1 * d1 % phi

        d2 = getPrime(int(n.bit_length()*0.16))
        e2, k = egcd(d2, phi)
        e2 = e2 * (phi + 1 - ed1) % phi
        ed2 = e2 * d2 % phi

        if GCD(e1, e2) > 10:
            break

    assert((ed1 + ed2) % phi == 1)

    return (n, (e1, d1), (e2, d2))

def process_chunk(chunk, n, A, B):
    M = int.from_bytes(chunk, 'big')
    C1 = pow(M, A[0], n)
    C2 = pow(M, B[0], n)
    assert(pow(C1, A[1], n) * pow(C2, B[1], n) % n == M)
    return (C1, C2)

chunks = [FLAG[i:i+128] for i in range(0, len(FLAG), 128)]
num_chunks = len(chunks)

output = f"{num_chunks}\n"

for chunk in chunks:
    n, A, B = generateKey()
    C1, C2 = process_chunk(chunk, n, A, B)
    
    output += f"n = {n}\n"
    output += f"e1 = {A[0]}\n"
    output += f"C1 = {C1}\n"
    output += f"e2 = {B[0]}\n"
    output += f"C2 = {C2}\n"
    output += "\n"

file = str(input("\nEnter file name: "))
file = file + ".txt"

with open(file, 'w') as f:
    f.write(output)

print(f"Output written to {file}")