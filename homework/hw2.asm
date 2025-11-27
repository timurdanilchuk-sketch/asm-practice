section .data
    buffer times 20 db 0      ; буфер под строку

section .text
    global _start

; ------------------------------
; int2str
; Вход:
;   eax — число
;   esi — адрес буфера (куда писать строку)
; Выход:
;   в буфере строка с числом (null-terminated)
; ------------------------------
int2str:
    mov ebx, 10              ; делитель
    xor ecx, ecx             ; counter символов (reverse)

.convert_loop:
    xor edx, edx             ; чистим edx перед div
    div ebx                  ; eax = eax/10, edx = остаток
    add dl, '0'              ; переводим остаток в символ
    mov [esi], dl            ; записываем
    inc esi                  ; двигаем буфер
    inc ecx                  ; считаем символы
    test eax, eax
    jnz .convert_loop

    dec esi                  ; esi ставим на последний символ

.reverse_loop:
    ; esi сейчас на конце, начальный адрес → esi - (ecx-1)
    mov edi, buffer
    add edi, ecx
    dec edi

    cmp esi, edi
    jge .done_reverse

    mov al, [esi]
    mov bl, [edi]
    mov [esi], bl
    mov [edi], al

    dec esi
    inc edi
    jmp .reverse_loop

.done_reverse:
    mov byte [buffer + ecx], 0  ; null-terminator
    ret



; -------------------------
;    MAIN
; -------------------------
_start:
    mov eax, 1234567
    mov esi, buffer
    call int2str

    ; print buffer
    mov edx, 20
    mov ecx, buffer
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
