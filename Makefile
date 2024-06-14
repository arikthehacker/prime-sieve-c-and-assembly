CC     ?= gcc
CFLAGS ?= -O2 -std=c11 -Wall

.PHONY: all run test clean

all:
	$(MAKE) -C c-sieve
	$(MAKE) -C nasm-sieve

# build the C sieve and run the example
run:
	$(CC) $(CFLAGS) -o sieve c-sieve/sieve.c
	@echo "primes up to 100:"
	@./sieve -p -u 100 | tr '\n' ' '; echo

test:
	@./test.sh

clean:
	rm -f sieve
	-$(MAKE) -C c-sieve clean
	-$(MAKE) -C nasm-sieve clean
