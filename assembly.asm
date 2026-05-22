;; Recursion, Loops, Printing to stdout
global _start

section .data
    kenobi:     db 10, "Hello, there!", 10, 0
    greivous:   db "General kenobi...", 10, 0
    answer_text:db 10, "factorial(", 0
    equals:     db ") = ", 0
    new_line:   db 10,0

section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

dispatch:
    mov rax, 1                  ; write syscall
    mov rdi, 1                  ; fd = 1 = stdout
    syscall                     ;
    mov rsp, rbp                ; restore base
    xor rbp, rbp                ;
    pop rbx                     ; restore flag for re-use
    ret                         ;

stringify_number:
    pop rax                     ; rdx:rax / rbx
    xor rdx, rdx                ; clear rdx - Upper word
    mov rbx, 10                 ; divisor = 10
    div rbx                     ;
    add rcx, 1                  ; length += 1
    add rdx, 48                 ; ASCII code for '0'
    push rdx                    ; Store remainder
    push rax                    ; This will pop off again in next loop
    cmp rax, 0                  ; if rax != 0
    jnz stringify_number        ;       loop
    imul rcx, 8                 ; 1 byte
    mov rdx, rcx                ; rdx = length = rcx
    sub rcx, 8                  ; Because we already start from first word (byte)
    sub rsi, rcx                ; Point to the first number (Because stack decreases.)
    jmp dispatch                ;

print_string:
    add rdx, 1                  ; index += 1
    movzx eax, byte [rdi + rdx] ; zero extend and copy byte. Using mov will assume 64-bit.
    cmp eax, 0                  ; if string[index] != 0
    jne print_string            ;       loop
    jmp dispatch                ;

display:
    push rbx                    ; store flag
    xor rax, rax                ; clear rax
    xor rcx, rcx                ; clear rcx
    xor rdx, rdx                ; start with rdx = length = 0
    xor rsi, rsi                ; clear rsi
    xor rbp, rbp                ; clear bp
    mov rbp, rsp                ; store base

    mov rsi, rdi                ; store pointer
    cmp rbx, 0                  ; if flag == 0 :
    jz print_string             ;    print string

    push [rdi]                  ; push number onto stack
    mov rsi, rsp                ; store address of number
    mov rax, [rsi]              ; store number in rax
    jmp stringify_number        ;

_start:
    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel kenobi]       ; arg1 = rdi = &string
    call display                ; rbx = flag (0 for string), arg1 = rdi = *int / *char

    lea rdi, [rel greivous]     ;
    call display                ;

    lea rdi, [rel answer_text]  ; print factorial(
    call display                ;

    mov rbx, 1                  ; print_number enabled
    push 10                     ; store n
    mov r10, rsp                ; store address for later
    mov rdi, rsp                ; arg1 = rdi = n
    call display                ;

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel equals]       ; print )=
    call display                ;

    mov rbx, 1                  ; print_number enabled
    mov rdi, [r10]              ; arg1 = n
    call factorial              ; arg1 = rdi = n, ret = rax

    push rax                    ; save factorial(n)

    mov rdi, rsp                ; arg1 = &number
    call display                ; rbx = flag (0 for string), arg1 = rdi = *int / *char


    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel new_line]     ; print \n
    call display                ;

    xor rdi, rdi                ; exit(0)
    jmp done                    ;

base:
    mov rax, 1                  ; Base-case n = 1
    ret                         ;

factorial:
    cmp rdi, 1                  ; if n <= 1 :
    jle base                    ;     result = 1
    push rdi                    ; save n
    sub rdi, 1                  ; n = n - 1
    call factorial              ; factorial (n-1)
    pop rdi                     ; restore n
    imul rax, rdi               ; result = result * n
    ret                         ;
