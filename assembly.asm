;; write syscall

global _start

section .data
    kenobi:     db 10, "Hello, there!", 10, 0 ; Null-terminated (\n = 10)
    greivous:   db "General kenobi...", 10, 0 ; Null-terminated

section .text

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

show:
    xor rax, rax
    xor rdx, rdx
    call find_new_line_char     ; stores length in rdx = arg4

    mov rax, 1                  ; syscall write()
    mov rdi, 1                  ; stdout (fd = 1)
    syscall
    ret

find_new_line_char:
    movzx eax, byte [rsi + rdx] ; zero extend and copy byte. Using mov will assume 64-bit.
    add rdx, 1                  ; index += 1
    cmp eax, 0                  ; if string[index] != 0
    jne find_new_line_char      ; loop
    ret                         ; rbx stores the number

_start:

    lea rsi, [rel kenobi]       ; arg1 = Pointer to buffer
    call show                   ; arg1 = rax = 1, arg2 = rdi = 1, arg3 = rsi, arg4 = rdx

    lea rsi, [rel greivous]     ; arg1 = Pointer to buffer
    call show                   ; arg1 = rax = 1, arg2 = rdi = 1, arg3 = rsi, arg4 = rdx

    mov rdi, 0                  ; exit(0)
    jmp done
