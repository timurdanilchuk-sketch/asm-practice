section .data
    msg_prime      db " - prime", 10, 0
    msg_not_prime  db " - not prime", 10, 0
    buffer         db 20 dup(0)

section .text
    global _start

; int2str: AX -> string in [ESI]
int2str:
    push ebx
    push ecx
    push edx

    movzx eax, ax
    mov ebx, 10
    xor ecx, ecx

.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi + ecx], dl
    inc ecx
    test eax, eax
    jnz .convert_loop

.reverse:
    mov eax, ecx
    dec eax
    xor edx, edx

.rev_loop:
    cmp edx, eax
    jge .done_reverse
    mov bl, [esi + edx]
    mov bh, [esi + eax]
    mov [esi + edx], bh
    mov [esi + eax], bl
    inc edx
    dec eax
    jmp .rev_loop

.done_reverse:
    mov byte [esi + ecx], 0
    pop edx
    pop ecx
    pop ebx
    ret

; is_prime: AX -> AL = 1 if prime, 0 otherwise
is_prime:
    push ebx
    push ecx
    push edx

    movzx eax, ax
    cmp eax, 2
    je .prime
    jb .not_prime

    mov ebx, 2

.check_loop:
    mov edx, 0
    mov ecx, eax        ; preserve number in ecx
    div ebx             ; eax = eax/ebx, edx = remainder
    cmp edx, 0
    je .not_prime
    mov eax, ecx        ; restore number to eax
    inc ebx
    cmp ebx, ecx
    jl .check_loop

.prime:
    mov al, 1
    pop edx
    pop ecx
    pop ebx
    ret

.not_prime:
    mov al, 0
    pop edx
    pop ecx
    pop ebx
    ret

_start:
    ; <-- Здесь можно изменить проверяемое число (в AX)
    mov ax, 37          ; пример: 37 (простое)

    ; печать числа
    mov esi, buffer
    call int2str

    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 20
    int 0x80

    ; проверка на простоту
    call is_prime

    cmp al, 1
    je .print_prime

.print_not:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_not_prime
    mov edx, 20
    int 0x80
    jmp .exit

.print_prime:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_prime
    mov edx, 20
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
