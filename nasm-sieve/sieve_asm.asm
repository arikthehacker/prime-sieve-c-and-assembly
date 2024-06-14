%define MARKED_FLAG 0x01                 ; flag to mark prime numbers
%define UNMARKED_FLAG 0x00               ; flag for unmarked numbers
%define LIMIT_TWO_BILLION 2000000000     ; upper limit for input validation

extern printf                            ; c function for output
extern scanf                             ; c function for input
extern malloc                            ; c function for memory allocation
extern free                              ; c function for freeing memory

global main                              ; entry point for the program

section .data                            ; data section, initialized variables
    prime_num:      dd 2                 ; initial prime number
    iterator:       dd 1
    primes_array:   dd 0x0               ; pointer to the array of primes

section .rodata                          ; read-only data section
    fmt_print:      db 10, "%d", 0       ; format for printing numbers
    fmt_newline:    db 10, 0
    fmt_input:      db "%d", 0           ; format for reading input
    prompt_msg:     db "Enter the upper bound of the prime numbers: ", 0
    error_ub:       db 10, "Upper bound is out of bounds [10 - 2000000000]", 10, 0
    error_alloc:    db 10, "Memory allocation failed. Exiting program.", 10, 0

section .bss                             ; BSS, uninitialized variables
    ub_limit:       resd 1

section .text                            ; code section

main:                                  
        push    ebp                      ; set up stack frame
        mov     ebp, esp

; --- get the upper bound from the user ---
get_upper_bound:
        push dword prompt_msg            ; push message to prompt for input
        call printf
        add esp, 4                       ; clean da stack
        push dword ub_limit
        push dword fmt_input             ; push format string for input
        call scanf                       ; call scanf to read user input
        add esp, 8                       ; clean da stack
        mov eax, [ub_limit]
        cmp eax, 10                      ; compare input with lower bound
        jl handle_invalid_ub             ; input < 10 then jump
        cmp eax, LIMIT_TWO_BILLION       ; comparison(input)->upper limit
        jg handle_invalid_ub
        jmp allocate_memory

; --- handle invalid upper bound input ---
handle_invalid_ub:
        push dword error_ub              ; err pushed
        call printf                      ; call printf to display err
        add esp, 4                       ; clean da stack
        jmp get_upper_bound

; --- allocate memory for prime numbers ---
; primes_array = malloc([ub_limit]); 
; if (primes_array == NULL)
; {
;   printf("Memory allocation failed. Exiting program.");
;   goto exit_program;
; }

allocate_memory:
        mov eax, [ub_limit]
        push eax
        call malloc
        test eax, eax                    ; malloc ok?
        jz handle_memory_fail
        mov [primes_array], eax
        add esp, 4                       ; clean da stack
        mov edi, eax                     ; move pointer to edi
        mov ecx, [ub_limit]              ; move ub to ecx
        dec ecx
        jmp init_array                   ; jump to init

; --- handle memory allocation failure ---
handle_memory_fail:
        push dword error_alloc           ; push err
        call printf
        add esp, 4
        jmp exit_program

; --- initialize the prime number array ---
init_array:
        mov byte [edi + ecx], 1          ; initialize array element to 1
        loop init_array
        mov byte [edi + ecx], 1

; --- start sieve of eratosthenes algorithm ---
sieve_primes:
        xor eax, eax
        mov ecx, 2
        mov ebx, [ub_limit]
        jmp outer_loop

next_prime:
        inc ecx                          ; increment counter!!!!

; --- outer loop for sieving primes ---
outer_loop:
        mov eax, ecx
        imul eax, eax                    ; square the counter!!!
        cmp eax, ebx                     ; compare with ub
        jge prepare_print
        cmp byte [edi + ecx], UNMARKED_FLAG
        je next_prime
        mov edx, ecx
        imul edx, 2                      ; double the counter

; --- inner loop for marking non-primes ---
inner_loop:
        cmp edx, ebx                     ; compare multiple with ub
        jge next_prime
        mov byte [edi + edx], 0
        add edx, ecx
        jmp inner_loop
        inc ecx

prepare_print:
        mov ecx, 2
        jmp print_loop                   ; jump to print loop

;;printf("%d\n", ecx);

print_prime:
        push dword ecx
        push ecx
        push dword fmt_print             ; push format string
        call printf
        add esp, 8                       ; clean up the stack
        pop ecx                          ; restore counter
        inc ecx
        cmp ebx, ecx
        jg print_loop                    ; continue printing if within bound

; --- loop to print primes ---
; for (int exc = 2; ecx <= [ub_limit]; exc++)
; {
;   if (primes_array[ecx] == 1) 
;   {
;       printf("%d\n", ecx);
;   } 
; }

print_loop:
        cmp byte [edi + ecx], MARKED_FLAG ; check if number is marked
        je print_prime
        inc ecx
        cmp ebx, ecx
        jg print_loop
        jmp exit_program

; --- clean up and exit ---
; free(primes_array);
; return 0 

exit_program:
        push dword fmt_newline           ; push newline format
        call printf                      ; call printf to print newline
        add esp, 4
        push dword [primes_array]        ; push allocated memory address
        call free
        add esp, 4
        mov esp, ebp                     ; restore stack pointer
        pop ebp                          ; restore base pointer
        mov eax, 0                       ; set return value to 0
        ret                              ; return from main

