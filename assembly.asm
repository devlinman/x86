;; Loops & Recursion

global _start
section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

sum_to_n:
    add rbx, 1                  ; rbx += 1
    add rax, rbx                ; rax = rax + rbx

    cmp rbx, rdi                ; if rbx < n
    jl sum_to_n                 ; recursive call

    ret

_start:
    mov rdi, 10                 ; input argument n = 10

    xor rax, rax                ;
    xor rbx, rbx                ;

    call sum_to_n
    mov rdi, rax                ; rdi = rax = 55

    jmp done                    ; exit(55)
