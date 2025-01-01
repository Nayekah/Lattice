from Crypto.Util.number import long_to_bytes
import time

file = str(input("Enter file name (without extension): "))
file = file + ".txt"

start = time.time()

try:
    with open(file, 'r') as f:
        lines = f.readlines()
        chunks = int(lines[0])
        print(f"Number of chunks: {chunks}")

        parameters = []
        current_line = 1
        
        for i in range(chunks):
            param_set = {
                'n': int(lines[current_line].strip().split('=')[1]),
                'e1': int(lines[current_line + 1].strip().split('=')[1]),
                'C1': int(lines[current_line + 2].strip().split('=')[1]),
                'e2': int(lines[current_line + 3].strip().split('=')[1]),
                'C2': int(lines[current_line + 4].strip().split('=')[1])
            }
            parameters.append(param_set)
            current_line += 6
        
except FileNotFoundError:
    print(f"Error: File '{file}' not found")
    exit()
except Exception as e:
    print(f"Error:  - An error occured while reading the file {str(e)}")
    exit()

def dot_product(v1, v2):
    return sum(a * b for a, b in zip(v1, v2))

def vector_sub(v1, v2):
    return [a - b for a, b in zip(v1, v2)]

def vector_add(v1, v2):
    return [a + b for a, b in zip(v1, v2)]

def scalar_mul(c, v):
    return [c * x for x in v]

def gram_schmidt_coefficient(u, v):
    return dot_product(v, u) / dot_product(u, u)

def gram_schmidt_process(basis):
    n = len(basis)
    orthogonal = [basis[0]]
    
    for i in range(1, n):
        vec = basis[i]
        for j in range(i):
            coeff = gram_schmidt_coefficient(orthogonal[j], basis[i])
            vec = vector_sub(vec, scalar_mul(coeff, orthogonal[j]))
        orthogonal.append(vec)
    
    return orthogonal

def LLL(matrix_input, delta=0.75):
    basis = [list(row) for row in matrix_input.rows()]
    n = len(basis)
    k = 1
    
    while k < n:
        for j in range(k-1, -1, -1):
            orthogonal = gram_schmidt_process(basis[:k+1])
            mu = gram_schmidt_coefficient(orthogonal[j], basis[k])
            if abs(mu) > 0.5:
                mu_rounded = round(mu)
                basis[k] = vector_sub(basis[k], scalar_mul(mu_rounded, basis[j]))
        
        orthogonal = gram_schmidt_process(basis[:k+1])
        prev_orth = gram_schmidt_process(basis[:k])
        
        lovasz_condition = (dot_product(orthogonal[k], orthogonal[k]) >= 
                        (delta - gram_schmidt_coefficient(orthogonal[k-1], basis[k])**2) * 
                        dot_product(orthogonal[k-1], orthogonal[k-1]))
        
        if lovasz_condition:
            k += 1
        else:
            basis[k], basis[k-1] = basis[k-1], basis[k]
            k = max(k-1, 1)
    
    return Matrix(ZZ, basis)

def decrypt_set(params, chunk_num):
    print(f"\nDecrypting chunk {chunk_num + 1}...")
    M = 2**512
    
    B = Matrix([
        [M, 0, params['e1']],
        [0, M, params['e2']],
        [0, 0, -params['n']],
    ])

    l = LLL(B)
    row = l[0]

    d1 = abs(row[0]) // M
    d2 = abs(row[1]) // M

    if pow(2, params['e1']*d1 + params['e2']*d2, params['n']) == 2:
        ans = pow(params['C1'], d1, params['n']) * pow(params['C2'], d2, params['n']) % params['n']
        try:
            msg = long_to_bytes(int(ans)).decode()
            print(f"Decrypted message for chunk {chunk_num + 1}: {msg}")
            return msg
        except:
            print(f"Failed to convert answer to bytes for chunk {chunk_num + 1}")
            return ""
    return ""

result = ""

for i, params in enumerate(parameters):
    result += decrypt_set(params, i)

print("\nFinal combined message:", result)
execution_time = time.time() - start
print(f"\nExecution time: {execution_time:.2f} seconds")