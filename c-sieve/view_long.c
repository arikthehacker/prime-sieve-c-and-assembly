#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    FILE *fp;
    unsigned long num;

    // Open the file provided as a command-line argument, or use stdin if no file is given.
    if (argc > 1)
    {
        fp = fopen(argv[1], "rb");
        if (!fp)
        {
            perror("Error opening file");
            return EXIT_FAILURE;
        }
    }
    else
    {
        fp = stdin;
    }

    // Read each unsigned long number and print it.
    while (fread(&num, sizeof(num), 1, fp) == 1)
    {
        printf("%lu\n", num);
    }

    // Close the file if it's not standard input.
    if (fp != stdin)
    {
        fclose(fp);
    }

    return 0;
}

