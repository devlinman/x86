;; Linux x86-64 syscall convention:

;; Meaning:Register
;; syscall number: RAX
;; arg1: RDI
;; syscall instruction: syscall
;;
;; For exit():
;; syscall number = 60
;; Argument:
;; exit code goes in RDI
;; Then:
;; syscall
;; executes kernel transition.

;; Use: mov, syscall
;; Set:
;; RAX = syscall number
;; RDI = exit code
;; Then invoke: syscall
;;

global _start

section .text

_start:
    mov rax, 60
    mov rdi, 70
    syscall
