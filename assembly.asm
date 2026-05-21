;; Functions, Stack

;; Functions: call, ret
;; Stack: push, pop

global _start
section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(12)

func:
    add rax, 5                  ; rax = 12
    ret

_start:
    mov rax, 7
    call func
    mov rdi, rax                ; rdi = 12

    push rax                    ; [rsp] = 12 (0xc)
    mov rax, 100                ; rax = 100
    pop rcx                     ; rcx = 12

    mov rdi, rcx                ; rdi = 12
    jmp done
