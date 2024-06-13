ARCH = -m32
PIE = -no-pie -fno-pie
LDFLAGS = $(ARCH) $(PIE)
ADEBUG = -g -O0
ASFLAGS = $(ADEBUG) -f elf32 -F dwarf

all: sieve_asm

sieve_asm: sieve_asm.o
		gcc $(LDFLAGS) -o sieve_asm sieve_asm.o

sieve_asm.o: sieve_asm.asm
		nasm $(ASFLAGS) -o sieve_asm.o sieve_asm.asm

clean:
	rm -f sieve_asm.o sieve_asm

