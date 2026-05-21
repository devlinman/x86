;; Loops & Recursion

global _start

section .data
    numbers: dq 1,2,3,4,5

section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

sum_array:
    add rax, [rdi + rbx * 8]    ; rax - accumulator
    add rbx, 1                  ; count += 1
    cmp rbx, rsi                ; if count < length
    jl sum_array                ; loop
    ret

_start:

    lea rdi, [rel numbers]      ; arg1 = Pointer to Array
    mov rsi, 5                  ; arg2  = length

    xor rax, rax
    xor rbx, rbx

    call sum_array

    mov rdi, rax                ; rdi = rax = 15
    jmp done                    ; exit(15)
