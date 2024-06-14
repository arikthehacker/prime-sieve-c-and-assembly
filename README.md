# prime-sieve-c-and-assembly

![language](https://img.shields.io/badge/language-C%20%26%20NASM-blue) ![platform](https://img.shields.io/badge/platform-Linux-lightgrey)
![CI](https://github.com/arikthehacker/prime-sieve-c-and-assembly/actions/workflows/ci.yml/badge.svg)

Finds every prime up to a bound with the Sieve of Eratosthenes, written three ways: a
plain C version, a bit-packed C version that uses half the memory, and a
32-bit NASM version.

## quickstart

```
git clone https://github.com/arikthehacker/prime-sieve-c-and-assembly.git
cd prime-sieve-c-and-assembly
sudo apt-get install -y build-essential nasm gcc-multilib
make run
```

expected output:

```
primes up to 100:
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

## how it works

The sieve marks multiples of each prime starting at `i*i`. The plain C version uses one
byte per number. The bit-packed version keeps two numbers per byte, one in the high
nibble and one in the low nibble, so the array is half the size:

```c
for (i = 2; i * i <= upper_bound; i++)
{
    if (i % 2 == 0 && (is_prime[i / 2] & LEFT_BITS) != 0) continue;
    if (i % 2 != 0 && (is_prime[i / 2] & RIGHT_BITS) != 0) continue;

    for (j = i * i; j <= upper_bound; j += i)
    {
        if (j % 2 == 0)
            is_prime[j / 2] |= LEFT_BITS;
        else
            is_prime[j / 2] |= RIGHT_BITS;
    }
}
```

The NASM version does the same marking by hand. It allocates the array with `malloc`,
fills it, runs the sieve loops over registers, then walks the array printing each number
still marked as prime:

```nasm
allocate_memory:
        mov eax, [ub_limit]
        push eax
        call malloc
        test eax, eax                    ; malloc ok?
        jz handle_memory_fail
        mov [primes_array], eax
        add esp, 4
        mov edi, eax                     ; array pointer
        mov ecx, [ub_limit]
        dec ecx
        jmp init_array
```

`samples/` holds gzipped prime lists for N from 10 up to 10,000,000. `regenerate.sh`
rebuilds the NASM sieve, regenerates those lists, and checks them against `SHA256SUMS`.
The three largest outputs (100,000,000, 1,000,000,000, 2,000,000,000) go up as release
assets; their SHA-256 values are in `SHA256SUMS`.

## options

The C sieve takes flags. Running `./sieve -h`:

```
Usage: sieve [-p|-c] [-u upper_bound] [-b] [-h]
  -p            print prime numbers 
  -c            print composite numbers
  -u            specify an upper bound 
  -b            output in binary format
  -h            print this help message
```

The NASM sieve reads the upper bound from standard input: `echo 100 | ./sieve_asm`.
