#!/usr/bin/env bash
#
# Rebuild the NASM sieve and check the committed sample prime lists against
# SHA256SUMS. The sieve reads the upper bound on stdin and prints a prompt plus
# the primes, so the prompt line is filtered out with grep before hashing.
#
# Requires (Linux): nasm and gcc with 32-bit support (e.g. the gcc-multilib
# package), plus gzip/zcat and sha256sum.
#
set -euo pipefail
cd "$(dirname "$0")"

echo "building nasm-sieve ..."
make -s -C nasm-sieve
SIEVE=./nasm-sieve/sieve_asm

emit() {            # emit N  ->  ascending primes up to N, one per line
    printf '%s\n' "$1" | "$SIEVE" | grep -E '^[0-9]+$'
}

rc=0
for gz in samples/primes_*.txt.gz; do
    base=$(basename "$gz" .gz)          # primes_N.txt
    N=${base#primes_}; N=${N%.txt}
    want=$(grep -E "  ${base}\$" SHA256SUMS | awk '{print $1}')
    regen=$(emit "$N" | sha256sum | awk '{print $1}')
    samp=$(zcat "$gz" | sha256sum | awk '{print $1}')
    if [ -n "$want" ] && [ "$want" = "$regen" ] && [ "$want" = "$samp" ]; then
        echo "ok    $base"
    else
        echo "FAIL  $base (recorded=$want regenerated=$regen sample=$samp)"
        rc=1
    fi
done

if [ "$rc" -eq 0 ]; then
    echo "all samples verified"
fi
exit $rc
