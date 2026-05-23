global _start

section .data
    kenobi:     db 10, "Hello, there!", 10, 0
    greivous:   db "General kenobi...", 10, 0
    b_read:     db " bytes read.", 10, 0
    prompt:     db 10, "Enter number: ", 0
    answer_text:db " Recieved.", 10, 10, "factorial(", 0
    equals:     db ") = ", 0
    new_line:   db 10,0
    error:      db 10, "Invalid string found", 10, 0

section .bss
    buffer: resb 128            ; reserve 128 bytes

section .text
invalid:
    xor rbx, rbx
    lea rdi, [rel error]
    call println
    mov rdi, 10
    jmp done

done:
    mov rax, 60                 ; rax = 60
    syscall                     ; exit(rdi)

print_dispatch:
    mov rax, 1                  ; write syscall
    mov rdi, 1                  ; fd = 1 = stdout
    syscall                     ;
    ret                         ;

print_number:
    pop rax                     ; rdx:rax / rbx
    xor rdx, rdx                ; clear rdx - Upper word
    mov rbx, 10                 ; divisor = 10
    div rbx                     ;
    add rcx, 1                  ; length += 1
    add rdx, 48                 ; ASCII code for '0'
    push rdx                    ; Store remainder
    push rax                    ; This will pop off again in next loop
    cmp rax, 0                  ; if rax != 0
    jnz print_number            ;       loop
    imul rcx, 8                 ; 1 byte
    mov rdx, rcx                ; rdx = length = rcx
    sub rcx, 8                  ; Because we already start from first word (byte)
    sub rsi, rcx                ; Point to the first number (Because stack decreases.)
    mov rsp, rbp                ; restore base
    xor rbp, rbp                ;
    pop rbx                     ; restore flag for re-use
    jmp print_dispatch          ;

print_string:
    add rdx, 1                  ; index += 1
    movzx eax, byte [rdi + rdx] ; zero extend and copy byte. Using mov will assume 64-bit.
    cmp eax, r10d               ; if string[index] != 0 (default) or some delimiter supplied
    jne print_string            ;       loop
    mov rsp, rbp                ; restore base
    xor rbp, rbp                ;
    pop rbx                     ; restore flag for re-use
    jmp print_dispatch          ;

println:
    push rbx                    ; store flag
    xor rax, rax                ; clear rax
    xor rcx, rcx                ; clear rcx
    xor rdx, rdx                ; start with rdx = length = 0
    xor rsi, rsi                ; clear rsi
    xor rbp, rbp                ; clear rbp
    mov rbp, rsp                ; store base
    mov rsi, rdi                ; store pointer
    cmp rbx, 0                  ; if flag == 0 :
    jz print_string             ;    print string
    push [rdi]                  ; push number onto stack
    mov rsi, rsp                ; store address of number
    mov rax, [rsi]              ; store number in rax
    jmp print_number            ;

read_line:
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
    cmp rax, 0
    jle invalid
    ret                         ;

_start:
    xor r10, r10                ; delimiter = 0, null-terminated
    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel kenobi]       ; arg1 = rdi = &string
    call println                ; rbx = flag (0 for string), arg1 = rdi = *int / *char, arg2 = r10 = delimiter byte

    lea rdi, [rel greivous]     ;
    call println                ;

    lea rdi, [rel prompt]
    call println

    lea rsi, [rel buffer]       ; address of buffer
    mov rdx, 128                ; Max. bytes
    call read_line              ;
    push rax                    ; store number of bytes read


    lea rdi, [rel buffer]       ; retrieve address of buffer
    mov r10, 10                 ; terminated by LF, delimiter = 10
    call println                ;
    xor r10, r10                ; continue printing null-terminated strings


    lea rdi, [rel buffer]       ; arg1 = &n
    pop rdx                     ; rdx = length (number of bytes read)
    call convert_buffer_to_number ; arg1 = rdi = pointer, arg2 = rdx = length
    push rax                      ;

    xor rbx, rbx                ;
    lea rdi, [rel answer_text]  ; print "factorial("
    call println                ;

    mov rbx, 1                  ;
    mov rdi, rsp                ; arg1 = rdi = &n
    call println                ;

    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel equals]       ; print ")="
    call println                ;

    pop rdi
    call factorial              ; arg1 = rdi = n, return = rax
    push rax                    ; save factorial(n)

    mov rdi, rsp                ; arg1 = &n
    mov rbx, 1
    call println


    xor rbx, rbx                ; print_string enabled
    lea rdi, [rel new_line]     ; print "\n"
    call println                ;

    xor rdi, rdi                ; exit(0)
    jmp done                    ;

base:
    mov rax, 1                  ; Base-case n = 1
    ret

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
    xor rax, rax
    xor rcx, rcx
    sub rdx, 1
.loop:
    movzx rsi, byte [rdi + rcx]

    cmp rsi, '0'
    jl invalid
    cmp rsi, '9'
    jg invalid

    sub rsi, '0'
    imul rax, 10
    add rax, rsi
    add rcx, 1
    cmp rcx, rdx
    jl .loop

    ret
