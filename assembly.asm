;; Stack frames, Local variables

;;  push rbp; mov rbp, rsp;   ;;   ;mov rsp, rbp; pop rbp;
;; |<--    prologue    -->|<-func->|<--   epilogue    -->|

;; [rax] - memory access

global _start
section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

func:
    push rbp                    ; Prologue:
    mov rbp, rsp                ; store this stack pointer in rbp
    ;; enter                       ; equivalent to above two steps
    ;; enter <<stacksize>>, 0      ; Not efficient
    ;; In this case, enter 8, 0

    sub rsp, 8                  ; Allocate 8 bytes

    mov [rbp - 8], 55           ; load 55 into memory
    mov rax, [rbp - 8]          ; Load from memory to rax

    mov rsp, rbp                ; restore rsp
    pop rbp                     ;
    ;; leave                       ; equivalent to above two steps
    ret                         ; clean return

_start:
    call func
    mov rdi, rax                ; rdi = 55

    jmp done                    ; exit(55)
