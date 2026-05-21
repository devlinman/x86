;; FLAGS

;; FLAGS drive control flow.
;; add, sub: These modify registers & FLAGS

;; Set:
;; rax = 10
;; Subtract:
;; 10
;; Then exit with:
;; code 0 if result became zero
;; code 1 otherwise


global _start
section .text

done:
    mov rax, 60
    syscall

equal:
    mov rdi, 0
    jmp done
diff:
    mov rdi, 1
    jmp done

_start:
    mov rbx, 20
    sub rbx, 10

    jz equal
    jmp diff
