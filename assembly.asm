;; Function Parameters
;; ABI conventions

global _start
section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

addnums:
    mov rax, rdi                ; rax = 20
    add rax, rsi                ; rax = 42
    ret

_start:
    mov rdi, 20                 ; arg1 = 20
    mov rsi, 22                 ; arg2 = 22

    call addnums
    mov rdi, rax                ; rdi = 42

    jmp done                    ; exit(42)
