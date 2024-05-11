DEBUG = -g3 -O0
WERROR = -Werror
CFLAGS = -Wall -Wshadow -Wunreachable-code -Wredundant-decls \
        -Wmissing-declarations -Wold-style-definition -Wmissing-prototypes \
        -Wdeclaration-after-statement -Wextra -Werror -Wpedantic \
        $(WERROR) $(DEBUG) $(DEFINES)

all: sieve view_long

sieve: sieve.o
		gcc $(CFLAGS) -o sieve sieve.o

view_long: view_long.o
		gcc $(CFLAGS) -o view_long view_long.o

sieve.o: sieve.c
		gcc $(CFLAGS) -c sieve.c

view_long.o: view_long.c
		gcc $(CFLAGS) -c view_long.c

clean:
		rm -f sieve view_long *.o
