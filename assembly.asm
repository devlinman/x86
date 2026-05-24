; assembly.asm
; Author: devlinman

global _start

section .data
    kenobi:     db 10, "Hello, there!", 10, 0
    greivous:   db "General kenobi...", 10, 0
    prompt:     db 10, "Enter a number to calculate factorial. (20 digits max)", 10, ">> ", 0
    b_read:     db " bytes recieved.", 10, "You entered: ", 0
    answer_text:db 10, 10, "factorial(", 0
    equals:     db ") = ", 0
    new_line:   db 10,0
    error:      db 10, 10, "Invalid input.", 10, "Exiting due to error.", 10, 0

section .bss
    buffer: resb 128            ; reserve 128 bytes

section .text
done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

invalid:                        ; A panic handler
    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel error]        ;
    call println                ; Print Error message
    mov rdi, 100                ; exit(100)
    jmp done                    ; What have I done!

print_dispatch:
    mov rax, 1                  ; write syscall
    mov rdi, 1                  ; fd = 1 = stdout
    syscall                     ; assuming rsi = pointer to buffer, rdx = length of buffer
    ret                         ;

println:
    push rbp                    ; store rbp
    mov rbp, rsp                ; save rsp
    push rbx                    ; store flag
    xor rax, rax                ; clear rax
    xor rcx, rcx                ; clear rcx
    xor rdx, rdx                ; start with rdx = length = 0
    xor rsi, rsi                ; clear rsi
    mov rsi, rdi                ; store pointer
    cmp rbx, 0                  ; if flag == 0 :
    jz .print_string            ;     print_string
    push [rdi]                  ; store stack
    mov rsi, rsp                ; store pointer to number
    mov rax, [rdi]              ; save number in rax
    jmp .print_number           ;
.print_string:
    add rdx, 1                  ; index += 1
    movzx eax, byte [rdi + rdx] ; zero extend and copy byte. Using mov will assume 64-bit.
    cmp eax, r10d               ; if string[index] != 0 (default) or some delimiter supplied
    jne .print_string           ;     loop
    pop rbx                     ; restore flag for re-use
    mov rsp, rbp                ; restore rsp
    pop rbp                     ; restore rbp
    jmp print_dispatch          ;
.print_number:
    xor rdx, rdx                ; rdx = Upper word = 0
    mov rbx, 10                 ; divisor = 10
    div rbx                     ; rdx:rax / rbx --> rdx = reaminder, rax = quotient
    add rdx, '0'                ; convert remainder to ASCII
    push rdx                    ; Store remainder
    add rcx, 1                  ; count += 1
    cmp rax, 0                  ; if rax (quotient) != 0
    jnz .print_number           ;     loop
    imul rcx, 8                 ; length = 1 byte * count
    mov rdx, rcx                ; rdx = length
    sub rsi, rcx                ; Point to the first number (Because stack decreases.)
    pop rbx                     ; restore flag for re-use
    mov rsp, rbp                ; restore rsp
    pop rbp                     ; restore rbp
    jmp print_dispatch          ;

readln:
    push rbx                    ; store flag
    xor rax, rax                ; read syscall 0
    xor rdi, rdi                ; fd = 0 = sdtin
    syscall                     ; assuming arg1 = rsi = pointer, arg2 = rdx = Max. bytes

    push rax                    ; store number of bytes read
    mov rdi, rsp                ; address of num_bytes_read
    mov rbx, 1                  ; print_number enabled
    call println                ;

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel b_read]       ; print "__ number of bytes read.\n"
    call println                ;
    pop rax                     ; return rax = number of bytes read.

    pop rbx                     ; restore flag
    cmp rax, 0                  ; if input.is_invalid:
    jle invalid                 ;     The negotiations _were_ short.
    ret                         ;

_start:
    xor r10, r10                ; delimiter = 0, null-terminated
    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel kenobi]       ; arg1 = rdi = &string
    call println                ; rbx = flag (0 for string), arg1 = rdi = *int / *char, arg2 = r10 = delimiter byte

    lea rdi, [rel greivous]     ; You're shorter than I expected.
    call println                ;

    lea rdi, [rel prompt]       ; Ah, yes. The negotiator.
    call println                ;

    lea rsi, [rel buffer]       ; address of buffer
    mov rdx, 128                ; Max. bytes
    call readln                 ; Your move.
    push rax                    ; store number of bytes read

    lea rdi, [rel buffer]       ; retrieve address of buffer
    mov r10, 10                 ; terminated by LF, delimiter = 10
    call println                ; Execute Order 66.
    xor r10, r10                ; continue printing null-terminated strings

    lea rdi, [rel buffer]       ; arg1 = &n
    pop rdx                     ; rdx = length (number of bytes read)
    call convert_buffer_to_number ; arg1 = rdi = pointer, arg2 = rdx = length, return = rax
    push rax                    ; <-------------- pushed here

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel answer_text]  ; print "factorial("
    call println                ;

    mov rbx, 1                  ; print_number enabled
    mov rdi, rsp                ; arg1 = rdi = &n
    call println                ; print n

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel equals]       ; print ")="
    call println                ;

    pop rdi                     ; ---------------> popped here
    call factorial              ; arg1 = rdi = n, return = rax

    push rax                    ; save factorial(n)
    mov rdi, rsp                ; arg1 = &n
    mov rbx, 1                  ; print_number enabled
    call println                ; print factorial(n)

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel new_line]     ; print "\n"
    call println                ;

    xor rdi, rdi                ; exit(0)
    jmp done                    ; In case I don't see ya: Good afternoon, Good evening, and Good night.

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

convert_buffer_to_number:
    xor rax, rax                ; result = 0
    xor rcx, rcx                ; index = 0
    sub rdx, 1                  ; pointer already at first byte
.loop:
    movzx rsi, byte [rdi + rcx] ;  rsi = *(pointer + index)

    cmp rsi, '0'                ;
    jl invalid                  ; Do or Do not.
    cmp rsi, '9'                ;
    jg invalid                  ; There is no try.

    sub rsi, '0'                ; __So uncivilized.__ convert byte to number
    imul rax, 10                ; result = result * 10
    add rax, rsi                ; result +=
    add rcx, 1                  ; index += 1
    cmp rcx, rdx                ; if index != length: loop
    jl .loop                    ; I'll try spinning. That's a good trick.

    ret                         ;


; Made with Doom Emacs 
