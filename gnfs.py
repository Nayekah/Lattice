import math

def calculate_gnfs_complexity(bit_size: int):
    op = 3e9  # 3 GHz
    cores = 1000
    constant = 1.923  # GNFS constant
    
    # Calculate n (the modulus)
    n = 2 ** bit_size
    
    # Calculate L(n) components
    ln_n = math.log(n)
    ln_ln_n = math.log(ln_n)
    
    # Time complexity L(n) = exp((c + o(1))(ln n)^(1/3)(ln ln n)^(2/3))
    exponent = constant * (ln_n ** (1/3)) * (ln_ln_n ** (2/3))
    operations = math.exp(exponent)
    
    #times
    total_op = op * cores
    theoretical_seconds = operations / total_op
    
    return theoretical_seconds

def analyze_rsa_factoring(bit_size: int):
    time = calculate_gnfs_complexity(bit_size)
    print(f"RSA-{bit_size}:")
    print(f"Theoretical time: {time:.2e} seconds")
    print(f"Optimized time: {time:.2e} seconds\n")

bit_sizes = [1024, 2048, 4096]
for size in bit_sizes:
    analyze_rsa_factoring(size)