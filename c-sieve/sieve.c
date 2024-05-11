#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define DEFAULT_UPPER 100

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
    char *is_prime;

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

    is_prime = calloc(upper_bound + 1, sizeof(char));

    for(unsigned long i = 2; i * i <= upper_bound; i++)
    {
        if(is_prime[i] == 0)
        {
            for(unsigned long j = i * i; j <= upper_bound; j += i)
            {
                is_prime[j] = 1;
            }
        }
    }

    if (binary_output)
    {
        for (unsigned long i = 2; i <= upper_bound; ++i)
        {
            if (is_prime[i] == !print_primes)
            {
                write(STDOUT_FILENO, &i, sizeof(i));
            }
        }
    }
    else
    {
        for (unsigned long i = 2; i <= upper_bound; ++i)
        {
            if (is_prime[i] == !print_primes)
            {
                printf("%lu\n", i);
            }
        }
    }

    free(is_prime);
    return 0;
}


