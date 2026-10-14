bits 32
section .data
    filename    db "output.txt", 0
    msg         db "Saved", 0xA
    msg_len     equ $ - msg
    seed        dd 12345678
    count_even  dw 0
    count_odd   dw 0
    count_ge50  dw 0
    count_lt10  dw 0

    hdr_even    db "Even numbers", 0xA
    len_he      equ $ - hdr_even
    hdr_odd     db 0xA, "Odd numbers", 0xA
    len_ho      equ $ - hdr_odd
    hdr_ge50    db 0xA, "Numbers >= 50000", 0xA
    len_hge     equ $ - hdr_ge50
    hdr_lt10    db 0xA, "Numbers < 10000", 0xA
    len_hlt     equ $ - hdr_lt10
    newline     db 0xA, 0

section .bss
    file_desc   resd 1
    data        resw 512
    rand_val    resw 1
    text_buf    resb 16384

section .text
    global _start

_start:
main_loop:
    mov eax, [seed]
    mov edx, 1103515245
    mul edx
    add eax, 12345
    mov [seed], eax
    shr eax, 16
    mov [rand_val], ax

    mov ax, [rand_val]
    test ax, 1
    jz handle_even
    jmp handle_odd

handle_even:
    movzx esi, word [count_even]
    cmp esi, 128
    jge check_ranges_s
    mov [data + esi * 2], ax
    inc word [count_even]
    jmp check_ranges_s

handle_odd:
    movzx esi, word [count_odd]
    cmp esi, 128
    jge check_ranges_s
    mov [data + 256 + esi * 2], ax
    inc word [count_odd]

check_ranges_s:
    mov ax, [rand_val]
    mov bx, 50000
    cmp ax, bx
    jb check_lt

    movzx esi, word [count_ge50]
    cmp esi, 128
    jge check_exit_condition
    mov [data + 512 + esi * 2], ax
    inc word [count_ge50]
    jmp check_exit_condition

check_lt:
    mov bx, 10000
    cmp ax, bx
    jae check_exit_condition

    movzx esi, word [count_lt10]
    cmp esi, 128
    jge check_exit_condition
    mov [data + 768 + esi * 2], ax
    inc word [count_lt10]

check_exit_condition:
    mov ax, [count_even]
    cmp ax, 128
    jge prepare_text
    mov ax, [count_odd]
    cmp ax, 128
    jge prepare_text
    mov ax, [count_ge50]
    cmp ax, 128
    jge prepare_text
    mov ax, [count_lt10]
    cmp ax, 128
    jge prepare_text

    jmp main_loop

prepare_text:
    mov edi, text_buf

    mov esi, hdr_even
    mov ecx, len_he
    cld
    rep movsb

    xor ecx, ecx
conv_even_loop:
    movzx eax, word [data + ecx * 2]
    push ecx
    call int_to_str
    pop ecx
    inc ecx
    cmp ecx, 128
    jl conv_even_loop

    mov esi, hdr_odd
    mov ecx, len_ho
    rep movsb

    xor ecx, ecx
conv_odd_loop:
    movzx eax, word [data + 256 + ecx * 2]
    push ecx
    call int_to_str
    pop ecx
    inc ecx
    cmp ecx, 128
    jl conv_odd_loop

    mov esi, hdr_ge50
    mov ecx, len_hge
    rep movsb

    xor ecx, ecx
conv_ge50_loop:
    movzx eax, word [data + 512 + ecx * 2]
    push ecx
    call int_to_str
    pop ecx
    inc ecx
    cmp ecx, 128
    jl conv_ge50_loop

    mov esi, hdr_lt10
    mov ecx, len_hlt
    rep movsb

    xor ecx, ecx
conv_lt10_loop:
    movzx eax, word [data + 768 + ecx * 2]
    push ecx
    call int_to_str
    pop ecx
    inc ecx
    cmp ecx, 128
    jl conv_lt10_loop

    jmp save_and_exit

int_to_str:
    mov ebx, 10
    mov esi, esp
convert_digits:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    test eax, eax
    jnz convert_digits

write_digits_to_buf:
    pop edx
    mov [edi], dl
    inc edi
    cmp esp, esi
    jne write_digits_to_buf

    mov byte [edi], ' '
    inc edi
    ret

save_and_exit:
    mov eax, 5
    mov ebx, filename
    mov ecx, 577
    mov edx, 420
    int 0x80

    test eax, eax
    js exit_prog
    mov [file_desc], eax

    mov eax, 4
    mov ebx, [file_desc]
    mov ecx, text_buf
    mov edx, edi
    sub edx, text_buf
    int 0x80

    mov eax, 6
    mov ebx, [file_desc]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, text_buf
    mov edx, edi
    sub edx, text_buf
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msg_len
    int 0x80

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80
