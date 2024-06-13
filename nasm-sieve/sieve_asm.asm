;; Ariella Marchuk   ||||   amarchuk@pdx.edu

%define MARKED_FLAG 0x01                 ; flag to mark prime numbers
%define UNMARKED_FLAG 0x00               ; flag for unmarked numbers
%define LIMIT_TWO_BILLION 2000000000     ; upper limit for input validation

extern printf                            ; c function for output
extern scanf                             ; c function for input
extern malloc                            ; c function for memory allocation
extern free                              ; c function for freeing memory

global main                              ; entry point for the program

section .data                            ; data section, initialized variables 
    iterator:       dd 1
    primes_array:   dd 0x0               ; pointer to the array of primes
    prime_num:      dd 2

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

get_input:
        push dword ub_limit
        push dword fmt_input             ; push format string for input
        call scanf                       ; call scanf to read user input
        add esp, 8                       ; clean da stack

        mov eax, [ub_limit]
        cmp eax, 10                      ; compare input with lower bound
        jl print_invalid_ub              ; if input < 10, print error
        cmp eax, LIMIT_TWO_BILLION       ; compare input with upper limit
        jg print_invalid_ub              ; if input > upper limit, print error
        jmp allocate_memory              

print_invalid_ub:
        push dword error_ub             
        call printf                      ; call printf to display error message
        add esp, 4                       ; clean da stack
        jmp exit_program                 ; exit program if invalid

; --- allocate memory for prime numbers ---
allocate_memory:
    mov eax, [ub_limit]
    push eax
    call malloc
    test eax, eax                    ; malloc ok?
    jz handle_memory_fail
    mov [primes_array], eax
    add esp, 4                       ; clean da stack
    mov edi, [primes_array]          ; move pointer to edi

    mov ecx, [ub_limit]              ; move upper bound to ecx
    xor eax, eax                     ; clear eax (to use as zero index)
    jmp initialize_array             ; jump to array initialization

; --- handle memory allocation failure ---
handle_memory_fail:
    push dword error_alloc           ; push error message
    call printf
    add esp, 4
    jmp exit_program

; --- initialize the prime number array ---
initialize_array:
.init_loop:
    mov byte [edi + eax], 1          ; set each element to 1
    inc eax                          ; increment index
    dec ecx                          ; decrement counter
    jnz .init_loop                   ; loop until ecx is zero

; --- sieve of eratos!!! ---
sieve_primes:
    xor eax, eax                      ; clear eax
    mov ecx, 2                        ; start with the first prime number
    mov ebx, [ub_limit]               ; upper bound in ebx

outer_loop:
    mov eax, ecx
    imul eax, ecx                     ; square the counter ecx
    cmp eax, ebx                      ; compare eax with upper bound
    jge prepare_print                 ; if squared value exceeds upper bound, prepare to print
    cmp byte [edi + ecx], UNMARKED_FLAG ; check if number is unmarked
    je increment_prime                ; if unmarked, go to next prime
    mov edx, ecx
    add edx, ecx                      ; double the counter

inner_loop:
    cmp edx, ebx                      ; compare edx with upper bound
    jge increment_prime               ; if edx exceeds upper bound, go to next prime
    mov byte [edi + edx], 0           ; mark multiple as non-prime
    add edx, ecx                      ; move to next multiple
    jmp inner_loop                  

increment_prime:
    inc ecx                           ; increment counter
    jmp outer_loop                 

prepare_print:
    mov ecx, 2                        ; start printing primes from 2
    jmp print_primes                  ; jump to print primes

; --- print those primes!!! ---
print_primes:
    mov ecx, 2                        ; start from the first prime number
    mov ebx, [ub_limit]               ; upper bound in ebx

print_loop:
    cmp ecx, ebx                      ; compare ecx with upper bound
    jg exit_program                   ; if ecx > upper bound, exit
    cmp byte [edi + ecx], MARKED_FLAG ; check if number is marked as prime
    jne increment_and_continue        ; if not marked, skip to next

    push dword ecx
    push ecx
    push dword fmt_print              ; push format string
    call printf
    add esp, 8                        ; clean up the stack
    pop ecx                           ; restore counter

increment_and_continue:
    inc ecx                           ; increment counter
    jmp print_loop                    ; repeat loop

; --- clean up and exit ---
exit_program:
    push dword fmt_newline           
    call printf                       
    add esp, 4                        ; clean up stack
    mov eax, [primes_array]         
    test eax, eax                     ; check if the address is not NULL
    jz .skip_free                     ; if NULL, skip the free call
    push eax                          ; push allocated memory address
    call free                         ; free allocated memory
    add esp, 4                        ; clean up stack
.skip_free:
    mov esp, ebp                   
    pop ebp                       
    xor eax, eax                      ; set return value to 0
    ret                               ; return from main

