#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>

#define DEFAULT_UPPER 100
#define LEFT_BITS 0xF0
#define RIGHT_BITS 0x0F

static void print_help(void)
{
    fprintf(stderr, "Usage: sieve [-p|-c] [-u upper_bound] [-b] [-h]\n");
    fprintf(stderr, "  -p            print prime numbers \n");
    fprintf(stderr, "  -c            print composite numbers\n");
    fprintf(stderr, "  -u            specify an upper bound \n");
    fprintf(stderr, "  -b            output in binary format\n");
    fprintf(stderr, "  -h            print this help message\n");
}

int main(int argc, char *argv[])
{
    long print_primes = 1;
    unsigned long upper_bound = DEFAULT_UPPER;
    long opt;
    int binary_output = 0;
    uint8_t *is_prime;
    size_t array_size;
    unsigned long i, j;

    while ((opt = getopt(argc, argv, "pcu:bh")) != -1)
    {
        switch (opt)
        {
            case 'p':
                print_primes = 1;
                break;
            case 'c':
                print_primes = 0;
                break;
            case 'u':
                upper_bound = atol(optarg);
                break;
            case 'b':
                binary_output = 1;
                break;
            case 'h':
                print_help();
                return 0;
            default:
                print_help();
                return 1;
        }
    }

    if (upper_bound < 2)
    {
        fprintf(stderr, "Error: upper bound should be at least 2\n");
        return 1;
    }

    // Allocate memory for the sieve
    array_size = (upper_bound + 1) / 2;
    is_prime = calloc(array_size, sizeof(uint8_t));
    if (!is_prime)
    {
        perror("calloc");
        return 1;
    }

    // Sieve of Eratosthenes
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

    if (binary_output)
    {
        for (i = 2; i <= upper_bound; ++i)
        {
            if ((i % 2 == 0 && (is_prime[i / 2] & LEFT_BITS) == 0) == print_primes ||
                (i % 2 != 0 && (is_prime[i / 2] & RIGHT_BITS) == 0) == print_primes)
            {
                write(STDOUT_FILENO, &i, sizeof(i));
            }
        }
    }
    else
    {
        for (i = 2; i <= upper_bound; ++i)
        {
            if ((i % 2 == 0 && (is_prime[i / 2] & LEFT_BITS) == 0) == print_primes ||
                (i % 2 != 0 && (is_prime[i / 2] & RIGHT_BITS) == 0) == print_primes)
            {
                printf("%lu\n", i);
            }
        }
    }

    free(is_prime);
    return 0;
}

