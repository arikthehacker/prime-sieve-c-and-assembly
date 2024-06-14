#!/usr/bin/env bash
# Build the C sieve and check that it prints the 25 primes under 100.
set -euo pipefail
cd "$(dirname "$0")"

CC="${CC:-gcc}"
bin="$(mktemp -u).sieve"
"$CC" -O2 -std=gnu11 -o "$bin" c-sieve/sieve.c

got=$("$bin" -p -u 100 | tr -d '\r' | tr '\n' ' ' | sed 's/ *$//')
rm -f "$bin"

expected="2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97"

if [ "$got" = "$expected" ]; then
    echo "PASS: 25 primes under 100"
    exit 0
else
    echo "FAIL: expected the 25 primes under 100"
    echo "  got: $got"
    exit 1
fi
